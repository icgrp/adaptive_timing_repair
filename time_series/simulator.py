import datetime
import random

def generate_measurements(conn, num_time_steps, time_interval_seconds):
    """
    Generate synthetic time-series measurements over a number of time steps.
    
    Each device's delay is based on a base value (depending on its type) that
    increases over time (aging) with added noise.
    """
    c = conn.cursor()
    # Retrieve all devices with their component types.
    c.execute("SELECT device_id, component_type FROM Devices")
    devices = c.fetchall()
    
    start_time = datetime.datetime.now()
    
    for t in range(num_time_steps):
        current_time = start_time + datetime.timedelta(seconds=t * time_interval_seconds)
        measurement_time_str = current_time.isoformat()
        print(f"Generating measurements for time step {t+1} at {measurement_time_str}...")
        for device_id, component_type in devices:
            # Set base delays by device type.
            if component_type == "register":
                base_delay = 0.5  # ns
            elif component_type == "lut6":
                base_delay = 0.3  # ns
            elif component_type == "lut5":
                base_delay = 0.2  # ns
            elif component_type == "pip":
                base_delay = 0.1  # ns
            else:
                base_delay = 0.3
            
            # Aging effect: delay increases slowly over time.
            aging = t * 0.001  # simple linear aging factor
            
            # Random noise added to the delay.
            noise = random.uniform(-0.05, 0.05)
            delay = base_delay * (1 + aging) + noise
            
            # Simulate temperature and voltage.
            temperature = random.uniform(40, 60)  # °C
            voltage = random.uniform(0.9, 1.1)      # V
            
            # Insert the measurement into the database.
            c.execute('''
            INSERT INTO Measurements (measurement_time, device_id, delay_ns, aging_factor, temperature, voltage)
            VALUES (?, ?, ?, ?, ?, ?)
            ''', (measurement_time_str, device_id, delay, aging, temperature, voltage))
        conn.commit()
