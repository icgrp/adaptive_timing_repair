import sqlite3

def create_db(db_path):
    """
    Create a new SQLite database (or overwrite if exists) with two tables:
    Devices and Measurements.
    """
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    
    # Drop tables if they already exist
    c.execute("DROP TABLE IF EXISTS Devices")
    c.execute("DROP TABLE IF EXISTS Measurements")
    
    # Create the Devices table to store static FPGA device metadata.
    c.execute('''
    CREATE TABLE Devices (
        device_id INTEGER PRIMARY KEY AUTOINCREMENT,
        grid_x INT NOT NULL,
        grid_y INT NOT NULL,
        clb_side TEXT NOT NULL,           -- "left" or "right"
        component_type TEXT NOT NULL,     -- "register", "lut6", "lut5", or "pip"
        component_idx INT NOT NULL,       -- index within the CLB (e.g., 1..8 for registers)
        quadrant TEXT,                    -- e.g. "Q1", "Q2", "Q3", "Q4"
        description TEXT
    )
    ''')
    
    # Create the Measurements table for time-series data.
    c.execute('''
    CREATE TABLE Measurements (
        measurement_time TEXT NOT NULL,  -- ISO timestamp
        device_id INT NOT NULL,
        delay_ns REAL,                   -- measured delay (in nanoseconds)
        aging_factor REAL,               -- simple aging value
        temperature REAL,                -- temperature in °C
        voltage REAL,                    -- voltage in V
        PRIMARY KEY (measurement_time, device_id),
        FOREIGN KEY (device_id) REFERENCES Devices(device_id)
    )
    ''')
    conn.commit()
    return conn

def populate_devices(conn, grid_width, grid_height):
    """
    Populate the Devices table by iterating over each grid cell and adding
    device records for each CLB (left/right) with registers, LUTs, and pips.
    """
    c = conn.cursor()
    for x in range(grid_width):
        for y in range(grid_height):
            # Determine quadrant (example logic)
            if x < grid_width/2 and y < grid_height/2:
                quadrant = "Q1"
            elif x >= grid_width/2 and y < grid_height/2:
                quadrant = "Q2"
            elif x < grid_width/2 and y >= grid_height/2:
                quadrant = "Q3"
            else:
                quadrant = "Q4"
            for clb_side in ["left", "right"]:
                # 8 registers per CLB
                for reg in range(1, 9):
                    c.execute('''
                    INSERT INTO Devices (grid_x, grid_y, clb_side, component_type, component_idx, quadrant, description)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    ''', (x, y, clb_side, "register", reg, quadrant, f"Register {reg} in {clb_side} CLB"))
                # 4 6-LUTs per CLB
                for lut in range(1, 5):
                    c.execute('''
                    INSERT INTO Devices (grid_x, grid_y, clb_side, component_type, component_idx, quadrant, description)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    ''', (x, y, clb_side, "lut6", lut, quadrant, f"6-LUT {lut} in {clb_side} CLB"))
                # 4 5-LUTs per CLB
                for lut in range(1, 5):
                    c.execute('''
                    INSERT INTO Devices (grid_x, grid_y, clb_side, component_type, component_idx, quadrant, description)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    ''', (x, y, clb_side, "lut5", lut, quadrant, f"5-LUT {lut} in {clb_side} CLB"))
                # 4 pips (representing interconnect delays) per CLB.
                for pip in range(1, 5):
                    c.execute('''
                    INSERT INTO Devices (grid_x, grid_y, clb_side, component_type, component_idx, quadrant, description)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    ''', (x, y, clb_side, "pip", pip, quadrant, f"Pip {pip} for {clb_side} CLB"))
    conn.commit()
