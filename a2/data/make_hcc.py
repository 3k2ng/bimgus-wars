import sys
import gen_title
import hcc

data_dir = sys.argv[1]
title_data = gen_title.gen_data(f"{data_dir}/title_image.png")
char_set = hcc.hcc_encode(title_data["char_set"])
char_map = hcc.hcc_encode(title_data["char_map"])
color_map = hcc.hcc_encode(title_data["color_map"])

with open(f"{data_dir}/hcc_data.s", "w") as f:
    f.write(f"HCS_SIZE = {len(char_set)}\n")
    f.write(f"hcs_loc\n")
    f.write(f"\tdc.w hcc_char_set\n")
    f.write(f"hcc_char_set\n")
    f.write("\tdc.b " + ", ".join(["${:02x}".format(byte) for byte in char_set]) + "\n")

    f.write(f"HMAP_SIZE = {len(char_map)}\n")
    f.write(f"hmap_loc\n")
    f.write(f"\tdc.w hcc_char_map\n")
    f.write(f"hcc_char_map\n")
    f.write("\tdc.b " + ", ".join(["${:02x}".format(byte) for byte in char_map]) + "\n")

    f.write(f"HCM_SIZE = {len(color_map)}\n")
    f.write(f"hcm_loc\n")
    f.write(f"\tdc.w hcc_color_map\n")
    f.write(f"hcc_color_map\n")
    f.write(
        "\tdc.b " + ", ".join(["${:02x}".format(byte) for byte in color_map]) + "\n"
    )
