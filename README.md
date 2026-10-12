[![Language: Verilog](https://img.shields.io/badge/Language-Verilog%20%2F%20SystemVerilog-blue.svg)](https://en.wikipedia.org/wiki/Verilog)
[![Toolchain: EDA/FPGA](https://img.shields.io/badge/Tools-Questasim%20%7C%20Vivado-orange.svg)]()

# 🚗 FPGA Automotive Subsystems Control Suite

A collection of synthesizable, hardware-level automotive control modules designed in **Verilog/SystemVerilog** for FPGA deployment. This suite implements safety-critical vehicle dynamics, engine protection, dynamic aerodynamics, and driver assistance logic using a unified top-level ECU module that processes multiple sensory inputs concurrently without blocking or data hazards.

Detailed design calculations, block diagrams, and state machine specifications are documented in [`docs/project_report.pdf`](docs/project_report.pdf).

---

## 🌟 ECU Subsystems Overview

### 1. 🛑 Anti-lock Braking System (ABS) & Traction Control
* **Wheel Slip Calculation:** Computes real-time slip ratios by comparing wheel speed metrics against vehicle velocity.
* **PWM Torque Management:** Generates dynamic Pulse-Width Modulation (PWM) signals to reduce engine torque or regulate braking during wheel slip or lockup.

### 2. 🅿️ Obstacle Detection System
* **Proximity Calculation:** Uses a 16-bit sequential counter to measure the width of an incoming ultrasonic `echo_pulse`.
* **Dynamic Alerting:** Evaluates the pulse width; if it falls below the danger threshold (e.g., 5000 clock cycles), it instantly triggers an `alarm_led` warning of a dangerously close obstacle.

### 3. ⚙️ Multi-Mode Drive Controller (200V DC System)
* **Throttle Decoding:** A combinational decoder that maps a 2-bit throttle input and selectable drive modes (Eco, Normal, Sport, Track) to a target duty cycle.
* **PWM Generation:** Utilizes an 8-bit PWM generator counter to adjust the exact duty cycle for the 200V DC motor driver, outputting a precise `motor_pwm` signal.

### 4. 🛡️ Smart RPM Limiter & Engine Protection
* **Over-Rev Safeguard:** Features a hardware combinational comparator that continuously monitors an 8-bit `engine_rpm` input.
* **Safety Cut-off:** Instantly outputs an `ignition_cut` signal if the engine redline threshold (e.g., > 200 RPM) is exceeded, ensuring immediate engine protection.

### 5. 🏎️ Dynamic Active Spoiler System
* **Speed-Dependent Deployment:** Employs an 8-bit vehicle speed monitoring comparator.
* **Automatic Trigger:** Generates a `spoiler_deploy` signal to automatically raise the rear aerodynamic wing when the vehicle's speed crosses a stability threshold (e.g., speed > 100).

---

## 🏗️ Top-Level Block Diagram

```text
+---------------------------------------------------------+
|         FPGA Automotive Subsystems Control Suite        |
|                                                         |
| [clk] ---------------->|  +-------------------------+   |
| [rst] ---------------->|  | 1. ABS & Traction Ctrl  |-------> [brake_pwm]
| [wheel_speed] -------->|  | - Slip Ratio Calc       |   |
| [vehicle_velocity] --->|  | - Dynamic PWM Manager   |-------> [torque_reduce]
|                        |  +-------------------------+   |
|                                                         |
| [echo_pulse] --------->|  +-------------------------+   |
|                        |  | 2. Obstacle Detection   |-------> [alarm_led]
|                        |  | - 16-bit Counter        |   |
|                        |  | - Comparator (< 5000)   |   |
|                        |  +-------------------------+   |
|                                                         |
| [throttle (2-bit)] --->|  +-------------------------+   |
| [drive_mode] --------->|  | 3. Motor Controller     |-------> [motor_pwm]
|                        |  | - Duty Cycle Decoder    |   | (To 200V DC Driver)
|                        |  | - 8-bit PWM Gen         |   |
|                        |  +-------------------------+   |
|                                                         |
| [engine_rpm (8-bit)] ->|  +-------------------------+   |
|                        |  | 4. RPM Limiter          |-------> [ignition_cut]
|                        |  | - Comparator (> 200)    |   |
|                        |  +-------------------------+   |
|                                                         |
| [vehicle_speed] ------>|  +-------------------------+   |
| (8-bit)                |  | 5. Active Aero System   |-------> [spoiler_deploy]
|                        |  | - Comparator (> 100)    |   |
|                        |  +-------------------------+   |
+---------------------------------------------------------+
