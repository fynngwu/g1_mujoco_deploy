#!/usr/bin/env bash
set -euo pipefail

echo "Stopping wbc_fsm session..."

# Kill wbc_fsm binary
pkill -f "./wbc_fsm" 2>/dev/null || true

# Kill simulated MuJoCo
pkill -f "./unitree_mujoco" 2>/dev/null || true

# Kill virtual keyboard publisher
pkill -f "virtual_keyboard_publisher.py" 2>/dev/null || true

# Kill tmux session if it exists
tmux kill-session -t wbc 2>/dev/null || true

echo "Stopped."
