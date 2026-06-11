#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WBC_FSM_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SIM_BUILD_DIR="${WBC_FSM_ROOT}/unitree_mujoco/simulate/build"
WBC_FSM_BIN="${WBC_FSM_ROOT}/build/wbc_fsm"

SIM_BIN="${SIM_BUILD_DIR}/unitree_mujoco"
CTRL_BIN="${WBC_FSM_BIN}"

usage() {
  cat <<'EOF'
Usage:
  run_g1_cpp_bridge.sh sim
  run_g1_cpp_bridge.sh ctrl
  run_g1_cpp_bridge.sh vkb [--domain-id 1 --interface lo]
  run_g1_cpp_bridge.sh check

Examples:
  ./run_g1_cpp_bridge.sh sim
  ./run_g1_cpp_bridge.sh ctrl
  ./run_g1_cpp_bridge.sh vkb --domain-id 1 --interface lo
  ./run_g1_cpp_bridge.sh check
EOF
}

check_bins() {
  local ok=1
  if [[ ! -x "${SIM_BIN}" ]]; then
    echo "[ERROR] Missing simulator binary: ${SIM_BIN}"
    ok=0
  fi
  if [[ ! -x "${CTRL_BIN}" ]]; then
    echo "[ERROR] Missing controller binary: ${CTRL_BIN}"
    ok=0
  fi
  if [[ "${ok}" -eq 0 ]]; then
    echo
    echo "Build with:"
    echo "  cd ${SIM_BUILD_DIR} && cmake .. && make -j\$(nproc)"
    echo "  cd ${WBC_FSM_ROOT}/build && cmake .. && make -j\$(nproc)"
    exit 1
  fi
}

cmd="${1:-}"
shift || true

case "${cmd}" in
  sim)
    check_bins
    cd "${SIM_BUILD_DIR}"
    exec ./unitree_mujoco "$@"
    ;;
  ctrl)
    check_bins
    cd "${WBC_FSM_ROOT}/build"
    exec ./wbc_fsm "$@"
    ;;
  vkb)
    exec python3 "${SCRIPT_DIR}/virtual_keyboard_publisher.py" "$@"
    ;;
  check)
    check_bins
    echo "[OK] Found simulator:  ${SIM_BIN}"
    echo "[OK] Found controller: ${CTRL_BIN}"
    ;;
  *)
    usage
    exit 2
    ;;
esac
