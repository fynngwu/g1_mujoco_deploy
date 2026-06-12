#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Install unitree_sdk2 if missing ──
UNITREE_DIR="/opt/unitree_robotics"
if [ ! -d "$UNITREE_DIR" ]; then
    echo "Installing unitree_sdk2 to ${UNITREE_DIR}..."
    git clone https://github.com/unitreerobotics/unitree_sdk2.git /tmp/unitree_sdk2
    cd /tmp/unitree_sdk2
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="$UNITREE_DIR"
    sudo make install -j"$(nproc)"
    cd /
    rm -rf /tmp/unitree_sdk2
    echo "unitree_sdk2 installed."
fi

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

# ── Ensure mujoco headers/libs are available ──
MUJOCO_DIR="${ROOT_DIR}/unitree_mujoco/simulate/mujoco"
MUJOCO_SYS_DIR="${HOME}/.mujoco/mujoco-3.3.6"
if [ ! -d "$MUJOCO_DIR" ]; then
    if [ -d "$MUJOCO_SYS_DIR" ]; then
        echo "Linking system MuJoCo..."
        ln -sf "$MUJOCO_SYS_DIR" "$MUJOCO_DIR"
    else
        if [ "$ARCH" = "x86_64" ]; then
            MUJOCO_TAR="mujoco-3.3.6-linux-x86_64.tar.gz"
        elif [ "$ARCH" = "aarch64" ]; then
            MUJOCO_TAR="mujoco-3.3.6-linux-aarch64.tar.gz"
        fi
        echo "Downloading ${MUJOCO_TAR}..."
        wget -q "https://github.com/google-deepmind/mujoco/releases/download/3.3.6/${MUJOCO_TAR}"
        mkdir -p "$MUJOCO_SYS_DIR"
        tar -xzf "$MUJOCO_TAR" -C "$MUJOCO_SYS_DIR" --strip-components=1
        rm -f "$MUJOCO_TAR"
        ln -sf "$MUJOCO_SYS_DIR" "$MUJOCO_DIR"
        echo "Done."
    fi
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

# ── Setup Python virtual env (uv) for virtual keyboard ──
echo "=== Setting up virtual keyboard Python env ==="
cd "${ROOT_DIR}/virtual_keyboard"
uv sync --python 3.10 --frozen 2>/dev/null || uv sync --python 3.10
echo ""

echo "Done. Binaries:"
ls -lh "${SIM_BUILD_DIR}/unitree_mujoco" "${CTRL_BUILD_DIR}/wbc_fsm" 2>/dev/null
