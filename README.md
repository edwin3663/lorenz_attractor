# Lorenz Attractor Simulation on an FPGA
Project Link: [peter.saffold.com](http://peter.saffold.com/lorenz.html)

This project computes the Lorenz system of differential equations and plots
the output in real-time to a SVGA monitor.

[![Image of Lorenz Attractor Simulation](http://img.youtube.com/vi/y6hWjaKDF-c/0.jpg)](http://www.youtube.com/watch?v=y6hWjaKDF-c)

## Required Software and Hardware
Xilinx Vivado 2018.3
Zedboard with Zynq-7000 All-Programmable SOC
SVGA capable monitor

## Building and Running the Project
1. Clone the project
2. Start Vivado 2018.3
3. To create the project in Vivado, type source ./attractor.tcl
4. To create the block design, type source ./block_design.tcl
5. Create a bitstream and load it onto the Zedboard

