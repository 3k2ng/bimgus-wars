with open("./data/level_num.txt", "r") as f:
    levels_str = f.readline()
    levels = int(levels_str)
with open("./zx02_level_data.s", "w") as f:
    for i in range(levels):
        f.write(f"level_{i+1}_data\n")
        f.write(f"\tincbin \"./data/level_{i+1}_data.zx02\"\n")
    f.write(f"level_data_table\n")
    f.write(f"\tdc.w ")
    for i in range(levels):
        f.write(f"level_{i+1}_data, ")
    f.write("0\n")
    
#
# level_1_data
#         incbin "./data/level_1_data.zx02"
# level_2_data
#         incbin "./data/level_2_data.zx02"
# level_data_table
#         dc.w level_1_data, level_2_data, 0
#