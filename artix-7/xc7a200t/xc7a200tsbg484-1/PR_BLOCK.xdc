#define a new pblock
create_pblock Data_Processor
add_cells_to_pblock [get_pblocks Data_Processor] [get_cells -quiet [list data_processing_1]]
resize_pblock [get_pblocks Data_Processor] -add {SLICE_X136Y84:SLICE_X139Y85}
#add a hierarchical module to the pblock
#define the size and components within the pblock


set_property BEL A5LUT [get_cells data_processing_1/inv4_inferred_i_1]
set_property LOC SLICE_X137Y85 [get_cells data_processing_1/inv4_inferred_i_1]
set_property BEL B6LUT [get_cells data_processing_1/inv1_inferred_i_1]
set_property LOC SLICE_X137Y85 [get_cells data_processing_1/inv1_inferred_i_1]
set_property BEL A6LUT [get_cells data_processing_1/inv2_inferred_i_1]
set_property LOC SLICE_X139Y85 [get_cells data_processing_1/inv2_inferred_i_1]
set_property BEL D6LUT [get_cells data_processing_1/inv3_inferred_i_1]
set_property LOC SLICE_X137Y85 [get_cells data_processing_1/inv3_inferred_i_1]

set_property BEL AFF [get_cells data_processing_1/normal_reg]
set_property LOC SLICE_X136Y85 [get_cells data_processing_1/normal_reg]


