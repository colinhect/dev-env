#!/usr/bin/env bash
# tmux-read.sh — scrape pane content, optionally trimmed to the last command's output.
#
# Uses tmux-read.py for intelligent prompt-based output extraction when
# available.  Falls back to raw scrollback if python3 is not found.
# Warns if the pane has a pending command tracked by tmux-exec.sh.
#
# Requires: bash ≥4.2, tmux (local)

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly SCRIPT_DIR
readonly STATE_DIR="${TMPDIR:-/tmp}/tmux-exec-state.${UID}"

die()  { printf '%s\n' "$*" >&2; exit 1; }
warn() { printf '%s\n' "$*" >&2; }

usage() {
    cat >&2 <<-'EOF'
	Usage: tmux-read.sh [-S SOCKET] [-n LINES] [-r] TARGET

	Read pane content, trimmed to the last command's output.

	TARGET format:
	  {session}:{window}.{pane}   fully qualified
	  {window}.{pane}             current session implied (from $TMUX)

	Options:
	  -n LINES   Scrollback depth (default: 2000).
	  -r         Raw mode — print full scrollback without trimming.
	  -S PATH    Custom tmux socket path.
	EOF
    exit 1
}

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

check_busy() {
    local pane_id=$1
    local sf="${STATE_DIR}/${pane_id//%/}"
    [[ -f ${sf} ]] || return 0
    local -A st=()
    local line key val
    while IFS= read -r line; do
        key=${line%%=*}; val=${line#*=}
        st[${key}]=${val}
    done < "${sf}"
    [[ -n ${st[started]-} ]] || return 0
    local now elapsed
    printf -v now '%(%s)T' -1
    (( elapsed = now - st[started] ))
    warn "Warning: Pane has a running command (${elapsed}s elapsed)."
    warn "  Command: ${st[command]-}"
    warn "  Output below may be incomplete."
    warn ""
}

main() {
    local -a sock=()
    local lines=2000 raw=0

    while getopts ':S:n:r' opt; do
        case ${opt} in
            S) sock=( -S "${OPTARG}" ) ;;
            n) lines=${OPTARG} ;;
            r) raw=1 ;;
            :) die "Option -${OPTARG} requires an argument." ;;
            *) usage ;;
        esac
    done
    shift $(( OPTIND - 1 ))
    (( $# >= 1 )) || usage

    local target
    target=$(resolve_target "$1" "${sock[@]}")

    local pane_id
    pane_id=$(tmux "${sock[@]}" display-message -p -t "${target}" \
                   '#{pane_id}' 2>/dev/null) \
        || die "Error: Target '${target}' not found. Use tmux-list.sh to list panes."
    [[ -n ${pane_id} ]] \
        || die "Error: Target '${target}' not found. Use tmux-list.sh to list panes."

    check_busy "${pane_id}"

    if (( raw )) || ! command -v python3 >/dev/null 2>&1; then
        tmux "${sock[@]}" capture-pane -t "${pane_id}" -p -S "-${lines}" 2>/dev/null
    else
        tmux "${sock[@]}" capture-pane -t "${pane_id}" -p -S "-${lines}" 2>/dev/null \
            | python3 "${SCRIPT_DIR}/tmux-read.py"
    fi
}

main "$@"
