#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Building unitree_mujoco (simulator) ==="
SIM_BUILD_DIR="${ROOT_DIR}/unitree_mujoco/simulate/build"
mkdir -p "$SIM_BUILD_DIR"
cd "$SIM_BUILD_DIR"
cmake ..
make -j"$(nproc)"
echo ""

echo "=== Building wbc_fsm (controller) ==="
CTRL_BUILD_DIR="${ROOT_DIR}/build"
mkdir -p "$CTRL_BUILD_DIR"
cd "$CTRL_BUILD_DIR"
cmake ..
make -j"$(nproc)"
echo ""

echo "Done. Binaries:"
ls -lh "${SIM_BUILD_DIR}/unitree_mujoco" "${CTRL_BUILD_DIR}/wbc_fsm" 2>/dev/null
