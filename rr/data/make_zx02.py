import subprocess


with open("./data/level_num.txt", "r") as f:
    levels_str = f.readline()
    levels = int(levels_str)

for i in range(levels):
    subprocess.run(['./data/zx02', f'./data/level_{i+1}_data.bin', f'./data/level_{i+1}_data.zx02'])

with open("./zx02_level_data.s", "w") as f:
    for i in range(levels):
        f.write(f"level_{i+1}_data\n")
        f.write(f"\tincbin \"./data/level_{i+1}_data.zx02\"\n")
    f.write(f"level_data_table\n")
    for i in range(levels):
        f.write(f"\tdc.w level_{i+1}_data\n")
    f.write("\tdc.w 0\n")
    
#
# level_1_data
#         incbin "./data/level_1_data.zx02"
# level_2_data
#         incbin "./data/level_2_data.zx02"
# level_data_table
#         dc.w level_1_data, level_2_data, 0
#