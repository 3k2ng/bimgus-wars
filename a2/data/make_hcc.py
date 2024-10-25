import sys
import gen_title
import hcc

data_dir = sys.argv[1]
title_data = gen_title.gen_data(f"{data_dir}/title_image.png")
char_set = title_data["char_set"]
char_map = hcc.hcc_encode(title_data["char_map"])
color_map = hcc.hcc_encode(title_data["color_map"])

with open(f"{data_dir}/hcc_data.s", "w") as f:
    f.write(f"TITLE_CHAR_SET_SIZE = {len(char_set)}\n")
    f.write(f"uncompressed_char_set\n")
    for i in range(0, len(char_set), 16):
        f.write(
            "\tdc.b "
            + ", ".join(["${:02x}".format(byte) for byte in char_set[i : i + 16]])
            + "\n"
        )

    f.write(f"hmap_loc\n")
    f.write(f"\tdc.w hcc_char_map\n")
    f.write(f"hcc_char_map\n")
    for i in range(0, len(char_map), 16):
        f.write(
            "\tdc.b "
            + ", ".join(["${:02x}".format(byte) for byte in char_map[i : i + 16]])
            + "\n"
        )

    f.write(f"hcm_loc\n")
    f.write(f"\tdc.w hcc_color_map\n")
    f.write(f"hcc_color_map\n")
    for i in range(0, len(color_map), 16):
        f.write(
            "\tdc.b "
            + ", ".join(["${:02x}".format(byte) for byte in color_map[i : i + 16]])
            + "\n"
        )
