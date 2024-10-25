import sys
import gen_title

data_dir = sys.argv[1]
title_data = gen_title.gen_data(f"{data_dir}/title_image.png")
char_set = title_data["char_set"]
char_map = title_data["char_map"]
color_map = title_data["color_map"]

with open(f"{data_dir}/uncompressed_data.s", "w") as f:
    f.write(f"TITLE_CHAR_SET_SIZE = {len(char_set)}\n")
    f.write(f"uncompressed_char_set\n")
    for i in range(len(char_set) // 8):
        f.write(
            "\tdc.b "
            + ", ".join(
                ["${:02x}".format(byte) for byte in char_set[i * 8 : (i + 1) * 8]]
            )
            + "\n"
        )

    f.write(f"umap_loc\n")
    f.write(f"\tdc.w uncompressed_char_map\n")
    f.write(f"uncompressed_char_map\n")
    for i in range(23):
        f.write(
            "\tdc.b "
            + ", ".join(
                ["${:02x}".format(byte) for byte in char_map[i * 22 : (i + 1) * 22]]
            )
            + "\n"
        )

    f.write(f"ucm_loc\n")
    f.write(f"\tdc.w uncompressed_color_map\n")
    f.write(f"uncompressed_color_map\n")
    for i in range(23):
        f.write(
            "\tdc.b "
            + ", ".join(
                ["${:02x}".format(byte) for byte in color_map[i * 22 : (i + 1) * 22]]
            )
            + "\n"
        )
