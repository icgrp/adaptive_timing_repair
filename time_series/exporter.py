import os
import pandas as pd

def export_measurements_to_csv(conn, output_dir):
    """
    Export a CSV file for each distinct measurement timestamp.
    Each CSV includes device location, type, and the measured values.
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        
    c = conn.cursor()
    c.execute("SELECT DISTINCT measurement_time FROM Measurements ORDER BY measurement_time")
    times = c.fetchall()
    
    for (measurement_time_str,) in times:
        query = '''
        SELECT d.grid_x, d.grid_y, d.clb_side, d.component_type, d.component_idx,
               m.delay_ns, m.aging_factor, m.temperature, m.voltage
        FROM Measurements m
        JOIN Devices d ON m.device_id = d.device_id
        WHERE m.measurement_time = ?
        '''
        df = pd.read_sql_query(query, conn, params=(measurement_time_str,))
        # Make the timestamp safe for a filename.
        safe_time = measurement_time_str.replace(":", "-")
        filename = os.path.join(output_dir, f"measurement_{safe_time}.csv")
        df.to_csv(filename, index=False)
        print(f"Exported measurements for {measurement_time_str} to {filename}")
