# G1 虚拟键盘与 Mimic 启动文件

这个仓库保存 G1 本地仿真用的虚拟手柄文件。当前版本支持：

- `Stand / Walk / Stop`
- `Dance` mimic：`L2(2s) + down`
- `Gangnam` mimic：`L2(2s) + left`
- 鼠标拖拽虚拟摇杆
- `WASD` 平移、`Q/E/Z/X` 转向

## 文件放置位置

本说明不依赖固定目录。先设置两个变量：

- `UNITREE_ROOT`：你的 Unitree RL Lab 根目录
- `VK_REPO`：本 `virtual_keyboard` 仓库目录

```bash
export UNITREE_ROOT=/path/to/unitree_rl_lab
export VK_REPO=/path/to/virtual_keyboard
```

把本仓库里的文件复制到 `unitree_deploy` 对应位置：

```bash
cd "$UNITREE_ROOT"

cp "$VK_REPO/run_g1_cpp_bridge.sh" \
  unitree_deploy/scripts/run_g1_cpp_bridge.sh

cp "$VK_REPO/virtual_controller_gui.py" \
  unitree_deploy/unitree_mujoco/simulate_python/virtual_controller_gui.py

cp "$VK_REPO/deploy/robots/g1_29dof/main.cpp" \
  unitree_deploy/deploy/robots/g1_29dof/main.cpp

chmod +x unitree_deploy/scripts/run_g1_cpp_bridge.sh
```

`virtual_keyboard_publisher.py` 仍然是虚拟键盘 DDS 发布脚本。如果目标仓库缺少它，也复制到：

```bash
cp "$VK_REPO/virtual_keyboard_publisher.py" \
  unitree_deploy/scripts/virtual_keyboard_publisher.py
```

## 前置配置

确认外层 MuJoCo 配置：

```text
$UNITREE_ROOT/unitree_mujoco/simulate/config.yaml
```

关键项应为：

```yaml
robot: "g1"
robot_scene: "scene_29dof.xml"
domain_id: 0
interface: "lo"
use_joystick: 0
use_virtual_keyboard: 1
enable_elastic_band: 1
```

确认 mimic policy 文件存在：

```text
unitree_deploy/deploy/robots/g1_29dof/config/policy/mimic/dance_102/exported/policy.onnx
unitree_deploy/deploy/robots/g1_29dof/config/policy/mimic/gangnam_style/exported/policy.onnx
```

## 编译

```bash
cd "$UNITREE_ROOT/unitree_deploy/deploy/robots/g1_29dof/build"
make -j$(nproc)
```

如果还没有 build 目录：

```bash
cd "$UNITREE_ROOT/unitree_deploy/deploy/robots/g1_29dof"
mkdir -p build
cd build
cmake ..
make -j$(nproc)
```

## 启动

打开 3 个终端，全部从根目录启动：

```bash
cd "$UNITREE_ROOT"
```

终端 A：

```bash
./unitree_deploy/scripts/run_g1_cpp_bridge.sh sim
```

终端 B：

```bash
./unitree_deploy/scripts/run_g1_cpp_bridge.sh ctrl -n lo
```

终端 C：

```bash
./unitree_deploy/scripts/run_g1_cpp_bridge.sh vkb --domain-id 0 --interface lo
```

也可以先检查二进制路径：

```bash
./unitree_deploy/scripts/run_g1_cpp_bridge.sh check
```

## 操作顺序

1. 在虚拟手柄窗口点击 `Stand`
2. 切到 MuJoCo 窗口，按 `8` 放下机器人
3. 回到虚拟手柄窗口，点击 `Walk`
4. 切到 MuJoCo 窗口，按 `9` 松开弹性绳
5. 点击 `Dance` 或 `Gangnam` 进入 mimic 动作

`Stop` 会发送 `L2 + B`，切回 `Passive`。

## 键位对应

- `Stand`：`L2 + up`
- `Walk`：`R1 + X`
- `Stop`：`L2 + B`
- `Dance`：`L2(2s) + down`
- `Gangnam`：`L2(2s) + left`
- 左摇杆 / `WASD` / 方向键：平移
- 右摇杆 / `Q/E/Z/X`：转向

## 常见问题

如果 `Dance/Gangnam` 没反应，优先检查：

- `ctrl` 是否运行的是 `unitree_deploy/deploy/robots/g1_29dof/build/g1_ctrl`
- `g1_29dof/main.cpp` 是否已经替换并重新编译
- `unitree_deploy/deploy/robots/g1_29dof/config/config.yaml` 中是否启用了 `Mimic_Dance_102` 和 `Mimic_Gangnam_Style`
- `sim`、`ctrl`、`vkb` 是否都使用 `domain_id = 0` 和 `interface = lo`
