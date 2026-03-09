#!/bin/bash

# Configuration
SESSION_NAME="ceph-cluster"

# 1. Check if the session exists; if not, create it
if ! tmux has-session -t $SESSION_NAME 2>/dev/null; then
    # Start new session (Pane 0 - Top Left)
    # -d means detached (background), so it works safely from inside or outside tmux
    P0=$(tmux new-session -d -s $SESSION_NAME -x 200 -y 100 -P -F "#{pane_id}")

    # --- Manual Grid Construction (3x2) ---
    P1=$(tmux split-window -h -t "$P0" -P -F "#{pane_id}")
    P2=$(tmux split-window -h -t "$P1" -P -F "#{pane_id}")
    tmux select-layout -t $SESSION_NAME even-horizontal

    P3=$(tmux split-window -v -t "$P0" -P -F "#{pane_id}")
    P4=$(tmux split-window -v -t "$P1" -P -F "#{pane_id}")
    P5=$(tmux split-window -v -t "$P2" -P -F "#{pane_id}")

    PANES=($P0 $P1 $P2 $P3 $P4 $P5)

    # 4. Send SSH commands
    tmux send-keys -t "${PANES[0]}" 'ssh ceph-adm' C-m
    tmux send-keys -t "${PANES[1]}" 'ssh ceph-mon' C-m
    tmux send-keys -t "${PANES[2]}" 'ssh ceph-osd-1' C-m
    tmux send-keys -t "${PANES[3]}" 'ssh ceph-osd-2' C-m
    tmux send-keys -t "${PANES[4]}" 'ssh ceph-osd-3' C-m
    tmux send-keys -t "${PANES[5]}" 'ssh ceph-osd-4' C-m

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
