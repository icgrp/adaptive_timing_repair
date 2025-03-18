##Description 
##This script handles creating PR partitions. 
##It create constraint files;
import serial
import time
from datetime import datetime

def write_bitstream (start, end): 
    with open ("D:/Downloads/IC2024/Data_Analysis/bitstream_writer.tcl", 'w') as f: 
        f.write(f'launch_runs impl_{start} -to_step write_bitstream -jobs 6\n')
        for i in range (start + 1, end):
         f.write(f'wait_on_run impl_{i - 1}\n')
         f.write(f'launch_runs impl_{i} -to_step write_bitstream -jobs 6\n')
#write_bitstream(2, 13)


def create_constraint (start, end, filename): 
    with open ("D:/Downloads/IC2024/Data_Analysis/create_constraint.tcl", 'w') as f: 
        for i in range (start, end):
         f.write(f'create_fileset -constrset constrs_{i}\n')
         f.write(f'file mkdir D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{i}\n')
         f.write(f'file mkdir D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{i}/new\n')
         f.write(f'close [ open D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{i}/new/const.xdc w ]\n')
         f.write(f'add_files -fileset constrs_{i} D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{i}/new/const.xdc\n')
         f.write(f'add_files -fileset constrs_{i} -norecurse D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{i}/new/const.xdc\n')
         f.write(f'close [ open D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{i}/new/placement.xdc w ]\n')
         f.write(f'add_files -fileset constrs_{i} D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{i}/new/placement.xdc\n')
         f.write(f'add_files -fileset constrs_{i} -norecurse D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{i}/new/placement.xdc\n')
         f.write(f'\n')
         f.write(f'#{i}')
         f.write(f'\n')

#create_constraint(2, 13, "left_measuring_right")

def LUT_PLACER_TILE1 (x_coordinate, y_coordinate, start, end, meas_x, meas_y, pblock_startx, pblock_starty, pblock_endx, pblock_endy, filename):
    #open file to write to. 
    for i in range (start, end): 
        with open(f'D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{i}/new/placement.xdc', 'w') as f: 
            f.write(f'create_pblock pblock_instance_i\n')
            f.write(f'add_cells_to_pblock [get_pblocks pblock_instance_i] [get_cells -quiet [list instance_i]]\n')
            f.write(f'resize_pblock [get_pblocks pblock_instance_i] -add {{SLICE_X{pblock_startx}Y{pblock_starty}:SLICE_X{pblock_endx}Y{pblock_endy}}}\n')
            
            f.write(f'# Early SAMPLE\n')
            f.write(f'set_property BEL AFF [get_cells instance_i/early_sample_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{meas_x}Y{meas_y} [get_cells instance_i/early_sample_reg_reg]\n')
            #I don't know where the operational_register is located. 
            #I could always introduce my own. Make the problem easier especially if there are multiple registers
            #connected to a node. 
            
            f.write(f'set_property BEL CFF [get_cells instance_i/meas_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/meas_reg_reg]\n')
            
            ##Operational Reg
            f.write(f'set_property BEL A5FF [get_cells instance_i/operational_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/operational_reg_reg]\n')
            ## Feeder_register 
            f.write(f'set_property BEL D5FF [get_cells instance_i/feeder_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/feeder_reg_reg]\n')
            #Feeder LUT 
            #Located in first SLICE_X0Y249
             
            
            f.write(f'# LUTs\n')
            row_offset = 0; 
            i = 0
            for j in range(4):
                if (j == 0):
                    f.write(f'set_property BEL A6LUT [get_cells instance_i/feeder_reg_inst]\n')
                    f.write (f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/feeder_reg_inst]\n')
                    f.write(f'set_property BEL A6LUT [get_cells instance_i/buff_inferred_i_{(14 - 2*i)}]\n')
                    f.write(f'set_property LOC SLICE_X{x_coordinate + 2*j - 1}Y{y_coordinate + row_offset} [get_cells instance_i/buff_inferred_i_{(14 - 2*i)}]\n')
                else:
                    if (j == 3):
                        f.write(f'set_property BEL A6LUT [get_cells instance_i/buff_inferred_i_{(14 - 2*i + 1)}]\n')
                        f.write(f'set_property LOC SLICE_X{x_coordinate + 2*j}Y{y_coordinate + row_offset} [get_cells instance_i/buff_inferred_i_{(14 - 2*i + 1)}]\n')
                        f.write(f'set_property BEL B6LUT [get_cells instance_i/buff_inferred_i_{14 - 2*i}]\n')
                        f.write(f'set_property LOC SLICE_X{x_coordinate + 2*j - 1}Y{y_coordinate + row_offset} [get_cells instance_i/buff_inferred_i_{14 - 2*i}]\n')
                    else: 
                        f.write(f'set_property BEL A6LUT [get_cells instance_i/buff_inferred_i_{(14 - 2*i + 1)}]\n')
                        f.write(f'set_property LOC SLICE_X{x_coordinate + 2*j}Y{y_coordinate + row_offset} [get_cells instance_i/buff_inferred_i_{(14 - 2*i + 1)}]\n')
                        f.write(f'set_property BEL A6LUT [get_cells instance_i/buff_inferred_i_{14 - 2*i}]\n')
                        f.write(f'set_property LOC SLICE_X{x_coordinate + 2*j - 1}Y{y_coordinate + row_offset} [get_cells instance_i/buff_inferred_i_{14 - 2*i}]\n')

                i +=1
            row_offset -= 1
            for j in range(4):
                if (j == 3): 
                    f.write(f'set_property BEL A6LUT [get_cells instance_i/buff_inferred_i_{(14 - 2*i + 1)}]\n')
                    f.write(f'set_property LOC SLICE_X{x_coordinate + 2*j}Y{y_coordinate + row_offset} [get_cells instance_i/buff_inferred_i_{(14 - 2*i + 1)}]\n')
                else:     
                    f.write(f'set_property BEL A6LUT [get_cells instance_i/buff_inferred_i_{(14 - 2*i + 1)}]\n')
                    f.write(f'set_property LOC SLICE_X{x_coordinate + 2*j}Y{y_coordinate + row_offset} [get_cells instance_i/buff_inferred_i_{(14 - 2*i + 1)}]\n')
                    f.write(f'set_property BEL A6LUT [get_cells instance_i/buff_inferred_i_{14 - 2*i }]\n')
                    f.write(f'set_property LOC SLICE_X{x_coordinate + 2*j - 1}Y{y_coordinate + row_offset} [get_cells instance_i/buff_inferred_i_{14 - 2*i }]\n')
                    i +=1
            ##Diff
            f.write(f'# Diff\n')
            f.write(f'set_property BEL AFF [get_cells instance_i/diff_reg]\n')
            f.write(f'set_property LOC SLICE_X4Y247 [get_cells instance_i/diff_reg]\n')
            f.write(f'set_property BEL A6LUT [get_cells instance_i/diff_i_1]\n')
            f.write(f'set_property LOC SLICE_X4Y247 [get_cells instance_i/diff_i_1]\n')


def lut_placer_SLICE (x_coordinate, y_coordinate, offset, meas_x, meas_y, pblock_startx, pblock_starty, pblock_endx, pblock_endy, filename):
    #open file to write to. 
    
    for i in range (1,5): 
        with open(f'D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{i + offset}/new/placement.xdc', 'w') as f: 
            f.write(f'create_pblock pblock_instance_i\n')
            f.write(f'add_cells_to_pblock [get_pblocks pblock_instance_i] [get_cells -quiet [list instance_i]]\n')
            f.write(f'resize_pblock [get_pblocks pblock_instance_i] -add {{SLICE_X{pblock_startx}Y{pblock_starty}:SLICE_X{pblock_endx}Y{pblock_endy}}}\n')
            
            f.write(f'# Early SAMPLE\n')
            f.write(f'set_property BEL AFF [get_cells instance_i/early_sample_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{meas_x}Y{meas_y} [get_cells instance_i/early_sample_reg_reg]\n')
            #I don't know where the operational_register is located. 
            #I could always introduce my own. Make the problem easier especially if there are multiple registers
            #connected to a node. 
            
            f.write(f'set_property BEL CFF [get_cells instance_i/meas_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/meas_reg_reg]\n')
            
            ##Operational Reg
            f.write(f'set_property BEL A5FF [get_cells instance_i/operational_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/operational_reg_reg]\n')
            ## Feeder_register 
            f.write(f'set_property BEL D5FF [get_cells instance_i/feeder_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/feeder_reg_reg]\n')
            #Location of the LUT being measured

            if (i == 0):
                f.write(f'set_property BEL A6LUT [get_cells instance_i/feeder_reg_inst]\n')
                f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/feeder_reg_inst]\n')
            
            elif (i == 1):
                f.write(f'set_property BEL B6LUT [get_cells instance_i/feeder_reg_inst]\n')
                f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/feeder_reg_inst]\n')
            
            elif (i == 2):
                f.write(f'set_property BEL C6LUT [get_cells instance_i/feeder_reg_inst]\n')
                f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/feeder_reg_inst]\n')
            else:
                f.write(f'set_property BEL D6LUT [get_cells instance_i/feeder_reg_inst]\n')
                f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/feeder_reg_inst]\n')

#one_lut_placer( 1, 0, 0, 0, 0, 0, 0, 7, 4, "left_measuring_right")           

#one_lut_placer( 2, 0, 4, 0, 0, 0, 0, 7, 4, "left_measuring_right")         
 
#one_lut_placer( 3, 0, 8, 0, 0, 0, 0, 7, 4, "left_measuring_right")
def individual_lut_placer (offset, meas_x, meas_y, x_coordinate, y_coordinate, pblock_startx, pblock_starty, pblock_endx, pblock_endy, filename): 
        with open(f'D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{offset}/new/placement.xdc', 'w') as f: 
            f.write(f'create_pblock pblock_instance_i\n')
            f.write(f'add_cells_to_pblock [get_pblocks pblock_instance_i] [get_cells -quiet [list instance_i]]\n')
            f.write(f'resize_pblock [get_pblocks pblock_instance_i] -add {{SLICE_X{pblock_startx}Y{pblock_starty}:SLICE_X{pblock_endx}Y{pblock_endy}}}\n')
            
            f.write(f'# Early SAMPLE\n')
            f.write(f'set_property BEL AFF [get_cells instance_i/early_sample_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{meas_x}Y{meas_y} [get_cells instance_i/early_sample_reg_reg]\n')
            #I don't know where the operational_register is located. 
            #I could always introduce my own. Make the problem easier especially if there are multiple registers
            #connected to a node. 
            
            f.write(f'set_property BEL CFF [get_cells instance_i/meas_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/meas_reg_reg]\n')
            
            ##Operational Reg
            f.write(f'set_property BEL A5FF [get_cells instance_i/operational_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/operational_reg_reg]\n')
            ## Feeder_register 
            f.write(f'set_property BEL D5FF [get_cells instance_i/feeder_reg_reg]\n')
            f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/feeder_reg_reg]\n')
            #Location of the LUT being measured

            f.write(f'set_property BEL D6LUT [get_cells instance_i/feeder_reg_inst]\n')
            f.write(f'set_property LOC SLICE_X{x_coordinate}Y{y_coordinate} [get_cells instance_i/feeder_reg_inst]\n')
             
def jtag_flash (start, end, filename): 
    with open ("D:/Downloads/IC2024/Data_Analysis/jtag_flasher.tcl", 'w') as f: 
        for i in range (start, end):
         f.write(f'#{i}\n')
         f.write(f'set_property PROBES.FILE {{}} [get_hw_devices xc7a200t_0]\n')
         f.write(f'set_property FULL_PROBES.FILE {{}} [get_hw_devices xc7a200t_0]\n')
         f.write(f'set_property PROGRAM.FILE {{D:/Downloads/IC2024/{filename}/{filename}.runs/impl_{i}/top.bit}} [get_hw_devices xc7a200t_0]\n')
         f.write(f'program_hw_devices [get_hw_devices xc7a200t_0]\n')
#jtag_flash(1,)
def const_create (start, end): 
    with open ("D:/Downloads/IC2024/Data_Analysis/const_creator_pr.tcl", 'w') as f: 
        for i in range (start, end):
         f.write(f'file mkdir D:Downloads/IC2024/slice_reconfiguration_pr/slice_reconfiguration_pr.srcs/constrs_{i}\n')
         f.write(f'file mkdir D:/Downloads/IC2024/slice_reconfiguration_pr/slice_reconfiguration_pr.srcs/constrs_{i}/new\n')
         f.write(f'close [ open D:/Downloads/IC2024/slice_reconfiguration_pr/slice_reconfiguration_pr.srcs/constrs_{i}/new/const.xdc w ]\n')
         f.write(f'add_files -fileset constrs_{i} D:/Downloads/IC2024/slice_reconfiguration_pr/slice_reconfiguration_pr.srcs/constrs_{i}/new/const.xdc\n')
         f.write(f'add_files -fileset constrs_{i} -norecurse D:/Downloads/IC2024/slice_reconfiguration_pr/slice_reconfiguration_pr.srcs/constrs_{i}/new/const.xdc\n')
         f.write(f'\n')
         f.write(f'#{i}')
         f.write(f'\n')

def reset_synth (start, end): 
    with open ("reset_synth_pr.tcl", 'w') as f: 
        f.write(f'reset_run cut_synth_1\n')
        for i in range (start, end):
         f.write(f'reset_run cut{i}_synth_1\n')

def uart_reciever_single_byte():
    # Configure the serial port
    ser = serial.Serial('COM3', 9600, timeout=1)  # Adjust the COM port and baud rate as needed
    counter = 0
    combined1 = 0
    combined2 = 0
    try:
        while True:
            if ser.in_waiting >= 2:  # Ensure there are at least 2 bytes in the buffer
                upper_byte = ser.read(1)  # Read the lower 8 bits
                lower_byte = ser.read(1)  # Read the upper 8 bits
                
                # Convert bytes to integers
                upper = int.from_bytes(lower_byte, byteorder='little')
                lower = int.from_bytes(upper_byte, byteorder='little')
                
                # Combine the lower and upper 8 bits into a 16-bit number
                
                combined1 = (lower << 8) | upper
                
                combined2 = (upper << 8) | lower

                #delay = 560 - combined 
                
                # Print the 16-bit number

            # if delay > 0 :
                counter += 1
                print(f'Received lower: {lower}\n')
                print(f'Received upper: {upper} \n')
                print(f'Delay 1:{counter}, {combined1}\n')
                print(f'Delay 2:{counter}, {combined2}\n')

                with open('slack_pr.csv', 'a') as f:
                    f.write(f'{counter}, {combined1}\n')
                    f.write(f'{counter}, {combined2}\n')
                ser.close()
                #time.sleep(20)
                ser =  serial.Serial('COM3', 9600, timeout=1)  # Adjust the COM port and baud rate as needed
                time.sleep(5)
    except KeyboardInterrupt:
        # Exit gracefully on keyboard interrupt
        print("Program interrupted")

    finally:
        ser.close()  # Close the serial port when done

def const_writer (start, end, filename):  
        for i in range (start, end):
            with open (f"D:/Downloads/IC2024/{filename}/{filename}.srcs/constrs_{i}/new/const.xdc", 'w') as f:
                f.write(f'set_property -dict {{PACKAGE_PIN R4 IOSTANDARD LVCMOS33}} [get_ports clk]\n')
                f.write(f'create_clock -period 10.000 -name sys_clk_pin -waveform {{0.000 5.000}} -add [get_ports clk]\n')
                f.write(f'set_property -dict {{PACKAGE_PIN AA19 IOSTANDARD LVCMOS33}} [get_ports tx]\n')
                f.write(f'set_property CONFIG_VOLTAGE 1.5 [current_design]\n')
                f.write(f'set_property CFGBVS GND [current_design]\n')

def cut_creator(start, end):
      with open ('D:/Downloads/IC2024/Data_Analysis/cut_creator_pr.tcl', "w") as f:
        for i in range (start, end):
            f.write(f'close [ open D:/Downloads/IC2024/slice_reconfiguration_pr/slice_reconfiguration_pr.srcs/sources_1/new/cut{i}.v w ]\n')
            f.write(f'add_files C:/Users/mavus/Downloads/IC2024/slice_reconfiguration_pr/slice_reconfiguration_pr.srcs/sources_1/new/cut{i}.v\n')     

def cut_writer(start, end):
    for i in range (start, end):
        with open (f'D:/Downloads/IC2024/slice_reconfiguration_pr/slice_reconfiguration_pr.srcs/sources_1/new/cut{i}.v') as f:
            f.write(f'')

def constraint_assignor (start, end, filename): 
    with open ("D:/Downloads/IC2024/Data_Analysis/constraint_set_assigner.tcl", 'w') as f: 
        for i in range (start, end):
         f.write(f'create_reconfig_module -name cut{i} -partition_def [get_partition_defs cut ]\n')
         f.write(f'add_files -norecurse D:/Downloads/IC2024/{filename}/{filename}.srcs/sources_1/new/circuit_under_test.v  -of_objects [get_reconfig_modules cut{i}]\n')
         f.write(f'create_pr_configuration -name config_{i} -partitions [list instance_i:cut{i} ]\n')
         f.write(f'create_run impl_{i} -parent_run synth_1 -constrset constrs_{i} -flow {{Vivado Implementation 2023}} -pr_config config_{i}\n')

def characterize_chip(x_offset, y_offset, start, end, my_range,  filename):
    create_constraint(start, end, filename)
    const_writer(start, end, filename)
    for i in range(my_range):
        individual_lut_placer(start + i, x_offset, y_offset + 25*i, x_offset + 2, y_offset + 25*i, x_offset, y_offset + 25*i, x_offset + 7, y_offset + 25*i + 4, filename)
    constraint_assignor(start, end, filename = "final_project")
    write_bitstream(start, end)
    jtag_flash(start, end, "left_measuring_right")
    

#characterize_chip(108,  50, 701, 707, 6,  "left_measuring_right")

#3.3 voltage 
#132 , 901 
#144, 1001
#156, 1101
#54, 301
#66, 401
#78, 501
#90, 601

#
#Characterize at different voltage
#characterize_chip(0, 0, 25001, 25011, 10, "left_measuring_right")
#characterize_chip(0, 0, 17001, 17011, 10, "left_measuring_right")
#characterize_chip(0, 0, 15001, 15011, 10, "left_measuring_right")

# def assign_lateness_blame ():
#     for 
#constraint_assignor(2, 13, "final_project")
##rite_bitstream_pr(2, 16)
#create_constraint(2, 15)
#const_create(2, 15)
#const_writer(1, 2, "left_measuring_right")
#LUT_PLACER_TILE1 (1, 249, 1, 15, 2, 247)
#cut_creator(3, 15)
uart_reciever_single_byte()
#jtag_flash(1, 16)
#one_lut_placer()
