# Neuromotor Interface for Modular Prosthetic Limb Hand Control

This project implements a neuromotor interface to control a simulated Modular Prosthetic Limb ([MPL](https://www.jhuapl.edu/work/projects-and-missions/revolutionizing-prosthetics/research)) Hand within the [MuJoCo HAPTIX](https://roboti.us/book/haptix.html) environment. Myoelectric signals are collected using a Backyard Brains [Muscle SpikerShield](https://docs.backyardbrains.com/retired/products/musclespikershieldbundle/) with a single EMG (electromyography) channel. These signals are processed and visualized in real-time using MATLAB, generating proportional control commands for the joint positions of the MPL Hand. The commands are then transmitted to the MuJoCo HAPTIX simulation environment for execution.

## Project Overview

The goal of this project is to create an intuitive interface between human muscle activity and a simulated robotic prosthetic hand. By leveraging EMG signals, the system translates neuromuscular activity into joint movements, providing a foundation for prosthetic control research and development.

### Key Components

- **Hardware**: Backyard Brains Muscle SpikerShield (1 EMG channel)
- **Signal Processing**: MATLAB for real-time signal processing, feature extraction, and visualization
- **Simulation**: MuJoCo HAPTIX environment for controlling the MPL Hand
- **Control**: Proportional control commands for joint positions

## Features

- Real-time EMG signal acquisition and processing
- Visualization of raw signals and extracted features in MATLAB
- Proportional control of MPL Hand joint positions
- Integration with the MuJoCo HAPTIX simulation platform

## Prerequisites

To run this project, you will need the following:

- **Hardware**:
  - Backyard Brains Muscle SpikerShield (with EMG electrodes)
  - Compatible microcontroller (Arduino UNO) for signal acquisition
- **Software**:
  - MATLAB (R2024a)
  - MuJoCo HAPTIX simulation environment
- **Operating System**: Windows (MATLAB and MuJoCo HAPTIX compatible)

## Usage

1. Hardware Setup:
   - Attach the EMG electrodes to the desired muscle group (e.g., forearm flexor muscles).
   - Connect the SpikerShield to your computer via USB
2. Run the MATLAB Script:
   - Open the main script (e.g., main.m) in MATLAB.
   - Run the script section by section to connect to the virtual environment, connect with arduino, and start signal acquisition, processing, and visualization.
3. Interact with MuJoCo HAPTIX:
   - The processed EMG signals will generate proportional joint commands, which are sent to the MPL Hand in the MuJoCo HAPTIX environment.
   - Observe the hand's movements in the simulation.

## License

This project is licensed under the MIT License. See the  file for details.
