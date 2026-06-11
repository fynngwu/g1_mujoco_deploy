#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONDA_PYTHON="/home/wufy/miniconda3/envs/wbc_vkb/bin/python3"

# Kill existing session if any
tmux kill-session -t wbc 2>/dev/null || true
sleep 0.5

tmux new-session -d -s wbc -n sim \
  "cd '$ROOT_DIR/unitree_mujoco/simulate/build' && DISPLAY=:1 ./unitree_mujoco; read"

sleep 2

tmux split-window -h -t wbc:sim \
  "cd '$ROOT_DIR/virtual_keyboard' && PATH=/home/wufy/miniconda3/envs/wbc_vkb/bin:\$PATH DISPLAY=:1 $CONDA_PYTHON virtual_keyboard_publisher.py; read"

sleep 2

tmux split-window -v -t wbc:sim.1 \
  "cd '$ROOT_DIR/build' && ./wbc_fsm; read"

tmux select-layout -t wbc:sim tiled 2>/dev/null
tmux select-pane -t wbc:sim.0

echo "wbc_fsm started. tmux session 'wbc' with 3 panes:"
echo "  pane 0: unitree_mujoco simulator"
echo "  pane 1: virtual keyboard"
echo "  pane 2: wbc_fsm controller"
echo ""
echo "Attach:  tmux attach -t wbc"
echo "Stop:    ./stop.sh"
