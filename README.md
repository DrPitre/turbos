# TurbOS

## Overview

**TurbOS** is a Real-Time Operating System (RTOS) for the [Turbo9](http://github.com/turbo9team/turbo9), a modern reimplementation of the classic 6809 CPU. Inspired by the 6809-based [OS-9 operating system](https://en.wikipedia.org/wiki/OS-9) (originally from [Microware Systems Corporation](http://www.microware.com/)) and the [NitrOS-9 Project](http://github.com/n6il/nitros9), TurbOS is designed to leverage the extensibility of the Turbo9, providing a flexible and modern RTOS environment. It is not tied to the legacy designs or assumptions of its predecessors.

### Key Features

- **Primary Target:** Turbo9 CPU, with additional ports for the Tandy Color Computer (CoCo) and Foenix F256 (FNX6809) for testing and bring-up.
- **Architecture:** Modular, with separate kernel, modules, and command sources.
- **Multi-Platform Support:**
  - **CoCo Port:** Builds a bootable disk image for use on real hardware or emulators.
  - **F256 Port:** Supports the Foenix F256, with build and upload tools.
  - **Turbo9 Simulator Port:** Enables development and testing on a Turbo9 simulator.
- **Testing:** Includes C-based utilities for run-length encoding/decoding and other validation.
- **Philosophy:** TurbOS aims to be the reference RTOS for the Turbo9, evolving alongside the CPU and supporting 6809 enthusiasts and developers.

### Directory Structure

- `ports/` — Platform-specific files for CoCo, F256, and Turbo9 simulator.
- `source/` — Core OS code: kernel, modules, commands.
- `tests/` — Test programs and utilities.

## FAQ

**Q. How do I run TurbOS on the Turbo9?**

**A.** The Turbo9 port of TurbOS is currently in progress. More information will be available in the future.

**Q. Will TurbOS run on 6809-based systems?**

**A.** The Turbo9 is the priority and the main target of TurbOS. There is a port to the Tandy Color Computer, mainly for testing and bring-up. Ports to other 6809 systems are possible, but aren't the focus of the project.
