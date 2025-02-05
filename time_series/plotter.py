import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

def plot_heatmap_for_time(conn, measurement_time_str, grid_width, grid_height):
    """
    Query the database to compute the average delay for all devices in each grid cell
    at a specific measurement time, and then plot a 2D heatmap.
    """
    query = '''
    SELECT d.grid_x, d.grid_y, AVG(m.delay_ns) as avg_delay
    FROM Measurements m
    JOIN Devices d ON m.device_id = d.device_id
    WHERE m.measurement_time = ?
    GROUP BY d.grid_x, d.grid_y
    ORDER BY d.grid_y, d.grid_x
    '''
    df = pd.read_sql_query(query, conn, params=(measurement_time_str,))
    
    # Create a matrix to hold average delays.
    heatmap = np.full((grid_height, grid_width), np.nan)
    for _, row in df.iterrows():
        x = int(row['grid_x'])
        y = int(row['grid_y'])
        heatmap[y, x] = row['avg_delay']
    
    plt.figure(figsize=(10, 8))
    im = plt.imshow(heatmap, cmap='viridis', origin='lower')
    plt.colorbar(im, label='Average Delay (ns)')
    plt.title(f"FPGA Average Delay Heatmap at {measurement_time_str}")
    plt.xlabel("Grid X")
    plt.ylabel("Grid Y")
    plt.tight_layout()
    plt.show()
