---
name: tmux
description: "Remote control tmux sessions for interactive CLIs (python, gdb, etc.) by sending keystrokes and scraping pane output."
---

# Tmux Skill

Simple, reliable tmux orchestration.  Works with **any remote pane** — the
target shell does not need `tmux` installed (completion is detected purely
through the local tmux `capture-pane` command).

## Setup — Pick a Target

Ask the user which pane to control.  Confirm with `tmux-list.sh`, then keep
the target string in context and pass it to every subsequent call.

```bash
./scripts/tmux-list.sh          # discover sessions/windows/panes
```

**Target format**: `{session}:{window}.{pane}`

| Example | Meaning |
|---------|---------|
| `work:1.0` | Session "work", window 1, pane 0 |
| `0:0.0` | First session, first window, first pane |

Once confirmed, reuse the same target for the entire conversation.

## Critical Rules

1. **Ask before targeting.**  Confirm the target pane with the user before
   sending any commands.
2. **Never create or destroy sessions** unless explicitly instructed.
3. **Never target the agent's own pane.**  `tmux-exec.sh` detects and refuses.
4. **Respect busy panes.**  If a pane is busy, wait or ask before retrying.
   Do not send `C-c` unless the user asks.
5. **No default timeout.**  Only pass `-t` when you have a good reason.
6. **Large output → redirect to file.**  The output is captured from the tmux
   scrollback buffer (default 5000 lines).  For large output redirect to a
   file on the remote:
   ```bash
   ./scripts/tmux-exec.sh "work:1.0" 'long-cmd > /tmp/out.txt 2>&1'
   ./scripts/tmux-exec.sh "work:1.0" 'cat /tmp/out.txt'
   ```

## How It Works

By default, `tmux-exec.sh` sends the command to the pane and **returns immediately**.
The agent then pauses and asks the user to confirm when the command has finished.
Once the user confirms, the agent calls `tmux-read.sh` to inspect the output.

This keeps the agent from blocking and lets the user stay in control of timing.

### Standard workflow

```
1. ./scripts/tmux-exec.sh "work:1.0" "npm test"   ← sends command, returns immediately
2. Agent: "Let me know when it finishes."
3. User: "Done."
4. ./scripts/tmux-read.sh "work:1.0"               ← scrape and interpret output
```

### Polling mode (`-p`) — sentinel-based completion detection

Enable with `-p` when you want the script to block until the command finishes and
return output + exit code automatically.  Useful for short, well-bounded commands.

`tmux-exec.sh -p` works by:
1. Injecting unique sentinel strings around the command in the pane.
2. Polling `tmux capture-pane` (locally) until the end sentinel appears.
3. Extracting output and exit code from the scrollback.

**No `tmux` binary is needed inside the target pane.**  This works correctly
over SSH, in containers, or any remote shell.

## 1. Execute (`scripts/tmux-exec.sh`)

Primary tool.  Sends a command to the target pane.

### Default mode (fire-and-forget)
Send a command and return immediately.  Ask the user to confirm when done,
then use `tmux-read.sh` to check the output.
```bash
./scripts/tmux-exec.sh "work:1.0" "ls -la"
```

### Polling mode (`-p`)
Block until the command finishes and return output + exit code:
```bash
./scripts/tmux-exec.sh -p "work:1.0" "ls -la"
```

### Interactive Mode (`-w PATTERN`)
Send keystrokes to a REPL and wait for a prompt regex:
```bash
./scripts/tmux-exec.sh -w '>>> ' "work:1.0" "print('hello')"
```

### Options
| Flag | Default | Meaning |
|------|---------|---------|
| `-p` | off | Polling mode: block until completion (sentinel-based). |
| `-t SEC` | none (wait forever) | Timeout. Only applies in polling/interactive mode. |
| `-w PATTERN` | — | Interactive mode: poll pane for regex. |
| `-S PATH` | — | Custom tmux socket. |

### Busy-pane protection (polling mode only)

If a previous polling command is still running the script refuses:
- **Sentinel found in scrollback** → command finished, proceeds normally.
- **Shell detected as current command** → assumes finished, proceeds.
- **State stale (>2h)** → cleared automatically.
- **Otherwise** → error with command name and elapsed time.

## 2. Read (`scripts/tmux-read.sh`)

Read-only scrape of pane content.  Trims to the last command's output
using prompt detection (requires `python3`; falls back to raw scrollback).

```bash
./scripts/tmux-read.sh "work:1.0"
./scripts/tmux-read.sh -r "work:1.0"   # raw (full scrollback)
```

| Flag | Default | Meaning |
|------|---------|---------|
| `-n LINES` | 2000 | Scrollback depth. |
| `-r` | — | Raw mode — skip prompt-trimming. |
| `-S PATH` | — | Custom tmux socket. |

## 3. List (`scripts/tmux-list.sh`)

JSON inventory of all panes with busy/idle state.

```bash
./scripts/tmux-list.sh
```

Use this to find the right target before executing commands.

## Interactive Tool Notes

### Python REPL
Always set `PYTHON_BASIC_REPL=1` — the fancy readline REPL breaks send-keys:
```bash
./scripts/tmux-exec.sh "work:1.0" 'PYTHON_BASIC_REPL=1 python3 -q'
./scripts/tmux-exec.sh -w '>>> ' "work:1.0" "print('hello')"
```

### Debuggers
Default to `lldb` (unless user says gdb).  Disable paging before sending commands.

## Error Handling

1. `tmux-read.sh TARGET` — inspect what's visible in the pane
2. `tmux-list.sh` — confirm target exists and check busy state
3. Test with `echo test` first
4. For complex issues read `references/error-handling-and-debugging.md`
