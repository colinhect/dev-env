#!/usr/bin/env bash
# tmux-exec.sh — send a command to a tmux pane, wait for completion,
#                return its output and exit code.
#
# Completion detected via unique sentinels printed to the pane and polled
# with capture-pane — no dependency on tmux being installed inside the
# target pane (works across SSH or any remote shell).
#
# Per-pane state files track running commands so concurrent or repeated
# calls can detect busy panes and recover cleanly.
#
# Requires: bash ≥4.2, tmux (local only), flock, awk, coreutils

set -euo pipefail

# ── constants ─────────────────────────────────────────────────────────────
readonly STATE_DIR="${TMPDIR:-/tmp}/tmux-exec-state.${UID}"
readonly SENTINEL_PFX="__TX${UID}__"   # unique-enough; all alphanum+underscore
readonly POLL_INTERVAL=0.1
readonly SCROLLBACK=5000

[[ -d ${STATE_DIR} ]] || { mkdir -p -- "${STATE_DIR}"; chmod 0700 -- "${STATE_DIR}"; }

# ── helpers ───────────────────────────────────────────────────────────────

die()  { printf '%s\n' "$*" >&2; exit 1; }
warn() { printf '%s\n' "$*" >&2; }

usage() {
    cat >&2 <<-'EOF'
	Usage: tmux-exec.sh [-p] [-w PATTERN] [-t TIMEOUT] [-S SOCKET] TARGET COMMAND

	Send COMMAND to a tmux pane.

	By default the script sends the command and returns immediately (exit 0).
	The user confirms when the command has finished; then use tmux-read.sh to
	inspect the output.

	Use -p to enable polling mode: the script blocks until the command
	completes and returns the output + exit code via sentinel markers.

	TARGET format:
	  {session}:{window}.{pane}   fully qualified
	  {window}.{pane}             current session implied (from $TMUX)

	Options:
	  -p           Poll mode: wait for command completion (sentinel-based).
	  -t SEC       Timeout in seconds (polling/interactive mode only).
	  -w PATTERN   Interactive mode: send keys and poll for a regex PATTERN
	               in the pane instead of waiting for command completion.
	  -S PATH      Custom tmux socket path.

	Exit codes (polling/interactive mode):
	  <N>   Command exit code (polling mode).
	  0     Pattern matched (interactive mode) or command sent (default mode).
	  1     Error (target not found, pane busy, self-target, …).
	  124   Timeout — command is STILL RUNNING in the pane.
	EOF
    exit 1
}

# Expand a short target (window.pane) with the current session name.
resolve_target() {
    local target=$1; shift
    local -a sock=( "$@" )
    [[ ${target} == *:* ]] && { printf '%s' "${target}"; return; }
    if [[ -n ${TMUX-} ]]; then
        local session
        session=$(tmux "${sock[@]}" display-message -p '#{session_name}' 2>/dev/null) || true
        [[ -n ${session} ]] && { printf '%s:%s' "${session}" "${target}"; return; }
    fi
    printf '%s' "${target}"
}

# ── state management ──────────────────────────────────────────────────────

write_state() {
    local sf=$1 command=$2 end_sentinel=$3
    printf 'command=%s\nend_sentinel=%s\nstarted=%(%s)T\n' \
        "${command}" "${end_sentinel}" -1 > "${sf}"
}

read_state() {
    local -n _map=$1; local sf=$2
    local line key val
    while IFS= read -r line; do
        key=${line%%=*}; val=${line#*=}
        _map["${key}"]=${val}
    done < "${sf}"
}

# Returns 0 (pane free) or 1 (still busy).
try_harvest_previous() {
    local sf=$1 pane_id=$2; shift 2
    local -a sock=( "$@" )
    [[ -f ${sf} ]] || return 0

    local -A prev=()
    read_state prev "${sf}"

    # No sentinel recorded — state from interactive mode or orphaned; clear it.
    if [[ -z ${prev[end_sentinel]-} ]]; then
        rm -f -- "${sf}"; return 0
    fi

    # Pane gone — command died with it.
    if ! tmux "${sock[@]}" display-message -p -t "${pane_id}" '#{pane_id}' \
            >/dev/null 2>&1; then
        rm -f -- "${sf}"; return 0
    fi

    # Check scrollback for the end sentinel (command finished).
    local buf
    buf=$(tmux "${sock[@]}" capture-pane -t "${pane_id}" -p \
              -S "-${SCROLLBACK}" 2>/dev/null) || true
    if [[ ${buf} == *"${prev[end_sentinel]}"* ]]; then
        rm -f -- "${sf}"; return 0
    fi

    # Fallback: if the pane is back at a shell, assume the command finished
    # (handles cases where scrollback was cleared and sentinel scrolled off).
    local cur_cmd
    cur_cmd=$(tmux "${sock[@]}" display-message -p -t "${pane_id}" \
                   '#{pane_current_command}' 2>/dev/null) || true
    if [[ ${cur_cmd} =~ ^(bash|zsh|sh|fish|dash|ksh|tcsh|csh)$ ]]; then
        rm -f -- "${sf}"; return 0
    fi

    # State file is stale (> 2h) — clear it.
    local now elapsed
    printf -v now '%(%s)T' -1
    (( elapsed = now - ${prev[started]:-0} ))
    if (( elapsed > 7200 )); then
        rm -f -- "${sf}"; return 0
    fi

    cat >&2 <<-EOF
	Error: Pane is busy — a previous command is still running.

	  Command : ${prev[command]-}
	  Running : ${elapsed}s

	Options:
	  1. Wait and retry.
	  2. Cancel:  tmux send-keys -t '${pane_id}' C-c
	  3. Use a different pane.
	EOF
    return 1
}

# ── shell mode — default: fire-and-forget; polling: sentinel-based ────────
#
# Default (poll=0): send the command and return immediately (exit 0).
#   The agent stops here; the user confirms when the command finishes;
#   the agent then calls tmux-read.sh to inspect the output.
#
# Polling (poll=1, enabled with -p): inject unique sentinels around the
#   command and poll capture-pane until the end sentinel appears, then
#   extract and return the output + exit code.  No tmux binary is needed
#   inside the target pane — works over SSH, in containers, etc.

exec_shell() {
    local pane_id=$1 sf=$2 lock=$3 target=$4 command=$5 timeout=$6 poll=$7
    shift 7
    local -a sock=( "$@" )

    (
        flock -x -w 5 200 \
            || die "Error: Another tmux-exec.sh is waiting on pane '${target}'."

        try_harvest_previous "${sf}" "${pane_id}" "${sock[@]}" || exit 1

        if [[ ${poll} == 0 ]]; then
            # ── fire-and-forget (default) ─────────────────────────────
            # Send the raw command; return immediately so the agent can
            # pause and let the user confirm completion before reading output.
            tmux "${sock[@]}" send-keys -t "${pane_id}" C-u
            tmux "${sock[@]}" send-keys -t "${pane_id}" -l -- "${command}"
            tmux "${sock[@]}" send-keys -t "${pane_id}" C-m
            exit 0
        fi

        # ── polling mode (-p) — sentinel-based completion detection ───

        # Unique sentinels for this invocation (alphanum + underscore only).
        local id
        id=$(date +%s%N 2>/dev/null || date +%s)
        local start_s="${SENTINEL_PFX}S${id}"
        local end_s="${SENTINEL_PFX}E${id}"

        write_state "${sf}" "${command}" "${end_s}"

        # Build payload sent to the pane's shell.
        # - echo start_s : marks where output begins in scrollback
        # - { cmd } 2>&1 : run command, merge stderr → stdout
        # - echo end_s $?: marks completion with exit code
        # Nothing here requires tmux or any special tool in the remote shell.
        local payload
        payload="echo ${start_s}; { ${command}; } 2>&1; echo \"${end_s} \$?\""

        tmux "${sock[@]}" send-keys -t "${pane_id}" C-u
        tmux "${sock[@]}" send-keys -t "${pane_id}" -l -- "${payload}"
        tmux "${sock[@]}" send-keys -t "${pane_id}" C-m

        flock -u 200  # release lock; state file now guards re-entry

        # ── poll scrollback until end sentinel appears ────────────────
        local start_t buf ec=-1
        printf -v start_t '%(%s)T' -1

        while true; do
            # Timeout check.
            if (( timeout > 0 )); then
                local now
                printf -v now '%(%s)T' -1
                if (( now - start_t >= timeout )); then
                    warn "Timeout after ${timeout}s — command is STILL RUNNING in the pane."
                    warn "Use tmux-read.sh to check progress, or send C-c to cancel."
                    exit 124
                fi
            fi

            # Liveness check.
            if ! tmux "${sock[@]}" display-message -p -t "${pane_id}" '#{pane_id}' \
                    >/dev/null 2>&1; then
                rm -f -- "${sf}"
                die "Error: Pane '${target}' died while command was running."
            fi

            buf=$(tmux "${sock[@]}" capture-pane -t "${pane_id}" -p \
                      -S "-${SCROLLBACK}" 2>/dev/null) || true

            if [[ ${buf} == *"${end_s}"* ]]; then
                # Extract exit code from the sentinel line (last word on the line).
                local ec_line
                ec_line=$(grep -F "${end_s}" <<< "${buf}" | tail -1)
                ec=${ec_line##* }
                [[ ${ec} =~ ^[0-9]+$ ]] || ec=0
                break
            fi

            sleep "${POLL_INTERVAL}"
        done

        # ── extract output: lines between start_s and end_s ──────────
        # awk uses index() for fixed-string matching (safe with special chars).
        # The command echo line also contains start_s, but awk skips it via
        # `next` before the print rule fires — so only the real output prints.
        local output
        output=$(awk -v s="${start_s}" -v e="${end_s}" \
            'index($0,s){f=1;next} f&&index($0,e){exit} f{print}' \
            <<< "${buf}")

        rm -f -- "${sf}"
        [[ -n ${output} ]] && printf '%s\n' "${output}"
        exit "${ec}"
    ) 200>"${lock}"
}

# ── interactive mode — polling for a regex in the pane ───────────────────
# Used for REPLs (python, gdb, etc.) where you send input and wait for
# a prompt pattern to reappear.  No sentinel needed.

exec_interactive() {
    local pane_id=$1 sf=$2 lock=$3 target=$4 command=$5 pattern=$6 timeout=$7
    shift 7
    local -a sock=( "$@" )

    (
        flock -x -w 5 200 \
            || die "Error: Another tmux-exec.sh is waiting on pane '${target}'."

        try_harvest_previous "${sf}" "${pane_id}" "${sock[@]}" || exit 1

        # Mark pane busy (no end_sentinel — cleared when pattern matches).
        write_state "${sf}" "${command}" ""

        tmux "${sock[@]}" send-keys -t "${pane_id}" C-u
        tmux "${sock[@]}" send-keys -t "${pane_id}" -l -- "${command}"
        tmux "${sock[@]}" send-keys -t "${pane_id}" C-m

        flock -u 200

        local start_t
        printf -v start_t '%(%s)T' -1

        while true; do
            if (( timeout > 0 )); then
                local now
                printf -v now '%(%s)T' -1
                if (( now - start_t > timeout )); then
                    warn "Timeout after ${timeout}s."
                    exit 124
                fi
            fi

            if ! tmux "${sock[@]}" display-message -p -t "${pane_id}" '#{pane_id}' \
                    >/dev/null 2>&1; then
                rm -f -- "${sf}"
                die "Error: Pane '${target}' died."
            fi

            local buf
            buf=$(tmux "${sock[@]}" capture-pane -t "${pane_id}" -p \
                      -S -500 2>/dev/null) || true

            if [[ ${buf} =~ ${pattern} ]]; then
                rm -f -- "${sf}"
                printf '%s\n' "${buf}"
                exit 0
            fi

            sleep "${POLL_INTERVAL}"
        done
    ) 200>"${lock}"
}

# ── main ──────────────────────────────────────────────────────────────────

main() {
    local timeout=0 pattern='' sock=() poll=0

    while getopts ':pw:t:S:' opt; do
        case ${opt} in
            p) poll=1 ;;
            w) pattern=${OPTARG} ;;
            t) timeout=${OPTARG} ;;
            S) sock=( -S "${OPTARG}" ) ;;
            :) die "Option -${OPTARG} requires an argument." ;;
            *) usage ;;
        esac
    done
    shift $(( OPTIND - 1 ))
    (( $# >= 2 )) || usage

    local target command=$2
    target=$(resolve_target "$1" "${sock[@]}")

    local pane_id
    pane_id=$(tmux "${sock[@]}" display-message -p -t "${target}" \
                   '#{pane_id}' 2>/dev/null) \
        || die "Error: Target '${target}' not found. Use tmux-list.sh to list panes."
    [[ -n ${pane_id} ]] \
        || die "Error: Target '${target}' not found. Use tmux-list.sh to list panes."

    [[ -z ${TMUX_PANE-} || ${pane_id} != "${TMUX_PANE}" ]] \
        || die "Error: Refusing to target the agent's own pane (${pane_id})."

    local sf="${STATE_DIR}/${pane_id//%/}"
    local lock="${STATE_DIR}/${pane_id//%/}.lock"

    if [[ -n ${pattern} ]]; then
        exec_interactive "${pane_id}" "${sf}" "${lock}" "${target}" \
                         "${command}" "${pattern}" "${timeout}" "${sock[@]}"
    else
        exec_shell "${pane_id}" "${sf}" "${lock}" "${target}" \
                   "${command}" "${timeout}" "${poll}" "${sock[@]}"
    fi
}

main "$@"
