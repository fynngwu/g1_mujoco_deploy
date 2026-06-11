# WBC_Deploy Controller

Whole-Body Control deployment system for humanoid robots using reinforcement learning and motion tracking.

English | [中文](README_zh.md)

## Features

- **State Machine Control**: Multiple FSM states including Passive, Loco (locomotion), and WBC (whole-body control)
- **Motion Tracking**: Real-time tracking of LAFAN1 motion dataset retargeted for Unitree G1 humanoid robots
- **ONNX Runtime**: Fast inference with ONNX models
- **Configurable**: JSON-based configuration for easy parameter tuning

## Prerequisites

- CMake >= 3.14
- C++17 compiler
- CUDA
- [uv](https://docs.astral.sh/uv/) (for Python virtual keyboard — `curl -LsSf https://astral.sh/uv/install.sh | sh`)
- System packages:

  ```bash
  sudo apt install libeigen3-dev nlohmann-json3-dev libboost-all-dev libssl-dev
  ```

## Quick Start

### 1. Build Everything

```bash
./build.sh
```

`build.sh` automatically:
- Installs `unitree_sdk2` to `/opt/unitree_robotics` (if not present)
- Downloads and extracts **ONNX Runtime 1.22.0** (if not present)
- Downloads and extracts **MuJoCo 3.3.6** (if not present)
- Sets up Python virtual env via `uv sync` for the virtual keyboard
- Builds `unitree_mujoco` simulator and `wbc_fsm` controller

### 2. Run

```bash
./start.sh    # starts simulator + virtual keyboard + controller in tmux
```

### 3. Stop

```bash
./stop.sh     # kills all processes and tmux session
```

## Usage Workflow

After `./start.sh`, three windows appear: MuJoCo viewer, Virtual Controller GUI, and the FSM terminal.

| Step | Action | Result |
|------|--------|--------|
| 1 | Click **Stand** in Virtual Controller GUI | Robot enters position-hold mode |
| 2 | Click **Walk** | Robot switches to Loco locomotion mode |
| 3 | Focus MuJoCo viewer, press **9** | Suspension band releases |
| 4 | Use joystick pads or WASD/arrows | Robot moves |

> The Virtual Controller GUI simulates an Xbox controller — click buttons and drag joystick pads with the mouse. Keyboard shortcuts: WASD = move, QEZX = turn.

**Note:** The **Dance** and **Gangnam** buttons are placeholders and have no effect.

All control is done through the Virtual Controller GUI (mouse or keyboard). No physical gamepad required.

## Configuration

### MJAMP Model

Place new ONNX model files in `model/loco/`, then edit `config/mjamp.json`:

```json
{
    "model_path": "model/loco/your_model.onnx",
    "safe_projgravity_threshold": 2.6,
    "vx_limit_min": -0.8,
    "vx_limit_max": 1.0,
    "vy_limit_min": -1.0,
    "vy_limit_max": 1.0,
    "wyaw_limit_min": -3.14,
    "wyaw_limit_max": 3.14,
    "cmd_smoothes": 0.0
}
```

### Virtual Keyboard Speed Limits

Edit `virtual_keyboard/virtual_keyboard_publisher.py` and adjust the scale constants at the top:

```python
LX_SCALE = 1.0   # strafe speed (A/D)
LY_SCALE = 3.0   # forward/back speed (W/S)
RX_SCALE = 1.0   # turn speed (Q/E)
```

## Project Structure

```
├── build.sh              # One-click build (auto-installs dependencies)
├── start.sh              # Launch simulator + keyboard + controller (tmux)
├── stop.sh               # Stop everything
├── CMakeLists.txt        # Controller build config
├── config/               # JSON configuration files
├── include/              # Header files
├── src/                  # Source files
│   ├── main.cpp
│   ├── control/
│   ├── FSM/
│   └── interface/
├── model/                # ONNX models
│   ├── loco/             # Locomotion / AMP / MJAMP models
│   └── wbc/              # WBC motion-tracking models
├── unitree_mujoco/       # MuJoCo simulator framework
├── virtual_keyboard/     # Virtual keyboard DDS publisher (uv-managed)
│   ├── pyproject.toml    # Python project config (uv)
│   └── run_g1_cpp_bridge.sh  # Manual per-component launcher
└── .gitignore
```

## License

This project is based on Unitree Robotics SDK2 framework.

Original framework: Copyright (c) 2020-2023, Unitree Robotics.Co.Ltd. All rights reserved.

Modified and extended by [ccrpRepo / ZSTU Robotics] © 2026

## Acknowledgments

- Based on [ccrpRepo/wbc_fsm](https://github.com/ccrpRepo/wbc_fsm) — the reference project this work is derived from
- Unitree Robotics SDK2
- LAFAN1 motion dataset
- ONNX Runtime for model inference
