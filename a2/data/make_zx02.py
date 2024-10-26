import sys

data_dir = sys.argv[1]

with open(f"{data_dir}/zx02_data.s", "w") as f:
    with open(f"{data_dir}/char_set.zx02", "rb") as fi:
        char_set = fi.read()

    with open(f"{data_dir}/char_map.zx02", "rb") as fi:
        char_map = fi.read()

    with open(f"{data_dir}/color_map.zx02", "rb") as fi:
        color_map = fi.read()

    f.write("zx02_char_set\n")
    for i in range(0, len(char_set), 16):
        f.write(
            "\tdc.b "
            + ", ".join(["${:02x}".format(byte) for byte in char_set[i : i + 16]])
            + "\n"
        )

    f.write("zx02_char_map\n")
    for i in range(0, len(char_map), 16):
        f.write(
            "\tdc.b "
            + ", ".join(["${:02x}".format(byte) for byte in char_map[i : i + 16]])
            + "\n"
        )

    f.write("zx02_color_map\n")
    for i in range(0, len(color_map), 16):
        f.write(
            "\tdc.b "
            + ", ".join(["${:02x}".format(byte) for byte in color_map[i : i + 16]])
            + "\n"
        )
