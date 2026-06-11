#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Auto-download onnxruntime if missing ──
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    ONNX_DIR="onnxruntime-linux-x64-1.22.0"
elif [ "$ARCH" = "aarch64" ]; then
    ONNX_DIR="onnxruntime-linux-aarch64-1.22.0"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

if [ ! -d "${ROOT_DIR}/${ONNX_DIR}" ]; then
    echo "Downloading ${ONNX_DIR}..."
    wget -q "https://github.com/microsoft/onnxruntime/releases/download/v1.22.0/${ONNX_DIR}.tgz"
    tar -xzf "${ONNX_DIR}.tgz"
    rm -f "${ONNX_DIR}.tgz"
    echo "Done."
fi

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
