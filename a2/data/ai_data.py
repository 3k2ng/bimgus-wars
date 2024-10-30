import sys

# Ensure there are 4 arguments: script name + 3 bin files + output directory
if len(sys.argv) != 5:
    print("Usage: script.py <char_set.bin> <char_map.bin> <color_map.bin> <output_dir>")
    sys.exit(1)

# Input .bin files and output directory from arguments
char_set_file = sys.argv[1]
char_map_file = sys.argv[2]
color_map_file = sys.argv[3]
data_dir = sys.argv[4]

# Helper function to read binary data from files
def read_bin_file(file_path):
    with open(file_path, "rb") as f:
        return f.read()

# Read binary data from the input files
char_set = read_bin_file(char_set_file)
char_map = read_bin_file(char_map_file)
color_map = read_bin_file(color_map_file)

# Generate the .s file in the specified output directory
# with open(f"{data_dir}/hcc_data.s", "w") as f:
with open(f"{data_dir}/rle_data.s", "w") as f:
    # Write char set size and uncompressed_char_set data
    f.write(f"TITLE_CHAR_SET_SIZE = {len(char_set)}\n")
    # f.write(f"TITLE_CHAR_SET_SIZE = 248\n")
    f.write(f"uncompressed_char_set\n")
    for i in range(0, len(char_set), 16):
        f.write(
            "\tdc.b "
            + ", ".join(["${:02x}".format(byte) for byte in char_set[i : i + 16]])
            + "\n"
        )

    # Write hmap_loc and char_map data
    f.write(f"hmap_loc\n")
    f.write(f"\tdc.w hcc_char_map\n")
    f.write(f"hcc_char_map\n")
    for i in range(0, len(char_map), 16):
        f.write(
            "\tdc.b "
            + ", ".join(["${:02x}".format(byte) for byte in char_map[i : i + 16]])
            + "\n"
        )

    # Write hcm_loc and color_map data
    f.write(f"hcm_loc\n")
    f.write(f"\tdc.w hcc_color_map\n")
    f.write(f"hcc_color_map\n")
    for i in range(0, len(color_map), 16):
        f.write(
            "\tdc.b "
            + ", ".join(["${:02x}".format(byte) for byte in color_map[i : i + 16]])
            + "\n"
        )
