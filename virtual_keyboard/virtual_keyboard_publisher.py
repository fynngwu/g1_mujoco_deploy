#!/usr/bin/env python3
"""
Virtual keyboard DDS publisher for wbc_fsm.

Configuration — edit these values directly:
"""
# ── Joystick dead zone (values below this are zeroed) ──
DEAD_ZONE = 0.01

# ── Exponential smoothing factor (0=no smoothing, 1=instant) ──
SMOOTH = 0.03

# ── Axis scale factors (GUI output -1~1 × scale = published value) ──
#     Set FSM config/*.json max_vx/max_vy/max_wz to 1.0 so scale = final speed.
#     GUI: W/S → ly (forward/back), A/D → lx (strafe), Q/E → rx (turn)
LX_SCALE = 1.0   # A/D left/right strafe speed
LY_SCALE = 3.0   # W/S forward/backward speed
RX_SCALE = 1.0   # Q/E turning speed
RY_SCALE = 1.0   # (unused by most FSM states)

# ── DDS ──
DOMAIN_ID = 1
INTERFACE = "lo"
HZ = 100.0

import argparse
import os
import sys
import time

from unitree_sdk2py.core.channel import ChannelFactoryInitialize, ChannelPublisher
from unitree_sdk2py.idl.unitree_go.msg.dds_ import WirelessController_
from unitree_sdk2py.idl.default import (
    unitree_go_msg_dds__WirelessController_ as WirelessControllerDefault,
)


def make_key_value(state: dict) -> int:
    key_map = {
        "R1": 0,
        "L1": 1,
        "start": 2,
        "select": 3,
        "R2": 4,
        "L2": 5,
        "F1": 6,
        "F2": 7,
        "A": 8,
        "B": 9,
        "X": 10,
        "Y": 11,
        "up": 12,
        "right": 13,
        "down": 14,
        "left": 15,
    }
    keys = 0
    for name, bit in key_map.items():
        v = 0
        if name in ("F1", "F2"):
            v = 0
        else:
            v = 1 if state.get(name, 0) else 0
        keys |= (v << bit)
    return keys


def apply_deadzone(val, dz):
    return 0.0 if abs(val) < dz else val

_smoothed = {"lx": 0.0, "ly": 0.0, "rx": 0.0, "ry": 0.0}

def smooth_and_scale(name, raw, smooth, scale):
    prev = _smoothed[name]
    filtered = prev * (1 - smooth) + raw * smooth
    _smoothed[name] = filtered
    return filtered * scale

def main():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    gui_path = os.path.join(root_dir, "unitree_mujoco", "simulate_python")
    if gui_path not in sys.path:
        sys.path.insert(0, gui_path)

    import pygame
    from virtual_controller_gui import VirtualControllerGUI

    ChannelFactoryInitialize(DOMAIN_ID, INTERFACE)
    pub = ChannelPublisher("rt/wirelesscontroller", WirelessController_)
    pub.Init()

    gui = VirtualControllerGUI(width=800, height=420)
    gui.init_display()

    dt = 1.0 / max(HZ, 1.0)
    print("Virtual keyboard publisher started.")
    print(f"  Domain: {DOMAIN_ID}, Interface: {INTERFACE}")
    print(f"  Scales — LX={LX_SCALE}  LY={LY_SCALE}  RX={RX_SCALE}  RY={RY_SCALE}")
    print(f"  Dead zone: {DEAD_ZONE}, Smooth: {SMOOTH}")
    print("WASD/Arrow=Move, Q/E/Z/X=Turn, buttons: Stand/Walk/Stop")

    while gui.running:
        t0 = time.perf_counter()
        gui.process_events()
        gui.render()

        state = gui.get_state()
        msg = WirelessControllerDefault()
        msg.keys = make_key_value(state)

        raw_lx = apply_deadzone(float(state.get("lx", 0.0)), DEAD_ZONE)
        raw_ly = apply_deadzone(float(state.get("ly", 0.0)), DEAD_ZONE)
        raw_rx = apply_deadzone(float(state.get("rx", 0.0)), DEAD_ZONE)
        raw_ry = apply_deadzone(float(state.get("ry", 0.0)), DEAD_ZONE)

        msg.lx = smooth_and_scale("lx", raw_lx, SMOOTH, LX_SCALE)
        msg.ly = smooth_and_scale("ly", raw_ly, SMOOTH, LY_SCALE)
        msg.rx = smooth_and_scale("rx", raw_rx, SMOOTH, RX_SCALE)
        msg.ry = smooth_and_scale("ry", raw_ry, SMOOTH, RY_SCALE)

        pub.Write(msg)

        elapsed = time.perf_counter() - t0
        if elapsed < dt:
            time.sleep(dt - elapsed)

    pygame.quit()


if __name__ == "__main__":
    main()
