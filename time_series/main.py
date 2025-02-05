import os
import sqlite3

from database import create_db, populate_devices
from simulator import generate_measurements
from exporter import export_measurements_to_csv
from plotter import plot_heatmap_for_time

def main():
    # Define file paths.
    db_path = os.path.join("..", "data", "fpga.db")
    export_dir = os.path.join("..", "data", "measurement_csv")
    
    # Define simulation parameters.
    grid_width = 20       # For demonstration. Use 1000 for full-scale simulation.
    grid_height = 20
    num_time_steps = 5
    time_interval_seconds = 60  # One measurement per minute.
    
    # 1. Create the database and tables.
    conn = create_db(db_path)
    print("Database created.")
    
    # 2. Populate the Devices table.
    populate_devices(conn, grid_width, grid_height)
    print("Devices table populated.")
    
    # 3. Generate synthetic measurements over time.
    generate_measurements(conn, num_time_steps, time_interval_seconds)
    print("Measurements generated.")
    
    # 4. Export CSV files for each measurement timestamp.
    export_measurements_to_csv(conn, export_dir)
    
    # 5. Plot a heatmap for the last measurement timestamp.
    c = conn.cursor()
    c.execute("SELECT measurement_time FROM Measurements ORDER BY measurement_time DESC LIMIT 1")
    last_time = c.fetchone()[0]
    print(f"Plotting heatmap for measurement time: {last_time}")
    plot_heatmap_for_time(conn, last_time, grid_width, grid_height)
    
    conn.close()

if __name__ == '__main__':
    main()
