#!/bin/bash

# Configuration
SESSION_NAME="ceph-local-osd"

# 1. Check if the session exists; if not, create it
if ! tmux has-session -t $SESSION_NAME 2>/dev/null; then
    # Start new session (Pane 0 - Top Left)
    # -d means detached (background), so it works safely from inside or outside tmux
    P0=$(tmux new-session -d -s $SESSION_NAME -x 200 -y 100 -P -F "#{pane_id}")

    # --- Manual Grid Construction (2x2) ---
    P1=$(tmux split-window -h -t "$P0" -P -F "#{pane_id}")
    tmux select-layout -t $SESSION_NAME even-horizontal

    P2=$(tmux split-window -v -t "$P0" -P -F "#{pane_id}")
    P3=$(tmux split-window -v -t "$P1" -P -F "#{pane_id}")

    PANES=($P0 $P1 $P2 $P3)

    # 4. Send SSH commands
    tmux send-keys -t "${PANES[0]}" 'ssh 192.168.202.231' C-m
    tmux send-keys -t "${PANES[1]}" 'ssh 192.168.202.232' C-m
    tmux send-keys -t "${PANES[2]}" 'ssh 192.168.202.233' C-m
    tmux send-keys -t "${PANES[3]}" 'ssh 192.168.202.234' C-m

    # 5. Setup Sync and Focus
    tmux set-window-option -t "${PANES[0]}" synchronize-panes on
    tmux select-pane -t "${PANES[0]}"
fi

# 2. DECISION: How do we enter the session?

if [ -n "$TMUX" ]; then
    # CASE A: We are ALREADY inside tmux.
    # We must use 'switch-client' to jump to the new session without nesting.
    tmux switch-client -t $SESSION_NAME
else
    # CASE B: We are in a normal terminal.
    # We attach normally.
    tmux attach -t $SESSION_NAME
fi