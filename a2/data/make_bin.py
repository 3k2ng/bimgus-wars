import sys
import gen_title

data_dir = sys.argv[1]
title_data = gen_title.gen_data(f"{data_dir}/title_image.png")
char_set = title_data["char_set"]
char_map = title_data["char_map"]
color_map = title_data["color_map"]

with open(f"{data_dir}/char_set.bin", "wb") as f:
    f.write(bytearray(char_set))

with open(f"{data_dir}/char_map.bin", "wb") as f:
    f.write(bytearray(char_map))

with open(f"{data_dir}/color_map.bin", "wb") as f:
    f.write(bytearray(color_map))
