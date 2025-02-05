# FPGA Time Series Repository

This project simulates a time-series repository for an FPGA. The FPGA is modeled as a grid (default 20×20 for demo purposes) where each cell contains two CLBs (left/right). Each CLB contains:
- 8 registers
- 4 6-LUTs
- 4 5-LUTs
- 4 pips (representing interconnect delays)

The repository is implemented using SQLite for the static device information and time-series measurements. The code generates synthetic measurement data over time, exports CSV files for each measurement timestamp, and plots a 2D heatmap showing regions with different average delays.

## Setup

1. **Install requirements:**  
   Run:
   ```bash
   pip install -r requirements.txt
