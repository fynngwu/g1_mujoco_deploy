# WBC_Deploy 控制器

基于强化学习和动作跟踪的人形机器人全身控制部署系统。

[English](README.md) | 中文

## 功能特性

- **状态机控制**：包含 Passive（阻尼保护）、Loco（行走）和 WBC（全身控制）等多种 FSM 状态
- **动作跟踪**：实时跟踪重定向到 Unitree G1 人形机器人的 LAFAN1 动作数据集
- **ONNX Runtime**：使用 ONNX 模型进行快速推理
- **可配置**：基于 JSON 的配置系统，便于模式切换和参数调整

## 环境要求

- CMake >= 3.14
- C++17 编译器
- CUDA
- [uv](https://docs.astral.sh/uv/)（用于管理虚拟键盘 Python 环境 — `curl -LsSf https://astral.sh/uv/install.sh | sh`）
- 系统依赖：

  ```bash
  sudo apt install tmux libeigen3-dev nlohmann-json3-dev libboost-all-dev libssl-dev
  ```

## 快速开始

### 1. 一键编译

```bash
./build.sh
```

`build.sh` 会自动：
- 安装 `unitree_sdk2` 到 `/opt/unitree_robotics`（如果未安装）
- 下载并解压 **ONNX Runtime 1.22.0**（如果不存在）
- 下载并解压 **MuJoCo 3.3.6**（如果不存在）
- 通过 `uv sync` 设置虚拟键盘的 Python 虚拟环境
- 编译 `unitree_mujoco` 模拟器和 `wbc_fsm` 控制器

### 2. 启动

```bash
./start.sh    # 同时启动模拟器 + 虚拟键盘 + 控制器（tmux 三面板）
```

### 3. 停止

```bash
./stop.sh     # 杀掉所有进程和 tmux 会话
```

## 使用流程

运行 `./start.sh` 后会弹出三个窗口：MuJoCo 仿真器、虚拟控制器 GUI、FSM 终端。

| 步骤 | 操作 | 结果 |
|------|------|------|
| 1 | 在虚拟控制器中点击 **Stand** | 机器人进入位置保持模式 |
| 2 | 点击 **Walk** | 机器人切换到 Loco 行走模式 |
| 3 | 焦点切到 MuJoCo 窗口，按 **9** | 松开悬吊绑带 |
| 4 | 拖动摇杆或按 WASD/方向键 | 机器人开始移动 |

> 虚拟控制器用鼠标点击按钮、拖动摇杆。键盘快捷键：WASD = 移动，QEZX = 转弯。

**注意：** **Dance** 和 **Gangnam** 按钮仅为占位，没有任何功能。

所有操作通过虚拟控制器 GUI 完成（鼠标或键盘），无需实体手柄。

## 配置文件

### MJAMP 模型

新 ONNX 模型文件放入 `model/loco/`，然后编辑 `config/mjamp.json`：

```json
{
    "model_path": "model/loco/你的模型.onnx",
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

### 虚拟键盘速度限幅

编辑 `virtual_keyboard/virtual_keyboard_publisher.py` 顶部的比例常量：

```python
LX_SCALE = 1.0   # 左右平移速度 (A/D)
LY_SCALE = 3.0   # 前后移动速度 (W/S)
RX_SCALE = 1.0   # 旋转速度 (Q/E)
```

## 项目结构

```
├── build.sh              # 一键编译（自动安装依赖）
├── start.sh              # 启动模拟器 + 键盘 + 控制器（tmux）
├── stop.sh               # 停止所有进程
├── CMakeLists.txt        # 控制器编译配置
├── config/               # JSON 配置文件
├── include/              # 头文件
├── src/                  # 源文件
│   ├── main.cpp
│   ├── control/
│   ├── FSM/
│   └── interface/
├── model/                # ONNX 模型
│   ├── loco/             # 行走 / AMP / MJAMP 模型
│   └── wbc/              # WBC 动作跟踪模型
├── unitree_mujoco/       # MuJoCo 模拟器框架
├── virtual_keyboard/     # 虚拟键盘 DDS 发布器（uv 管理）
│   ├── pyproject.toml    # Python 项目配置（uv）
│   └── run_g1_cpp_bridge.sh  # 手动单组件启动脚本
└── .gitignore
```

## 许可证

本项目基于 Unitree Robotics SDK2 框架开发。

原始框架：Copyright (c) 2020-2023, Unitree Robotics.Co.Ltd. 保留所有权利。

修改和扩展：[ccrpRepo / ZSTU Robotics] © 2026

## 致谢

- 参考自 [ccrpRepo/wbc_fsm](https://github.com/ccrpRepo/wbc_fsm) — 本项目完全基于该参考项目开发
- Unitree Robotics SDK2
- LAFAN1 动作数据集
- ONNX Runtime 模型推理
