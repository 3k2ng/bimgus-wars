import subprocess

with open("./data/title_zx02.s", "w") as f:
    with open("./data/bin_list.bin", "r") as bin_list:
        for line in bin_list:
            line = line.strip()
            # Compress the binary data
            subprocess.run(['./data/zx02', f'./data/{line}.bin', f'./data/{line}.zx02'])
            # Read the compressed data
            with open(f'./data/{line}.zx02', "rb") as fi:
                zx02_data = fi.read()
            # Write the compressed data to the final .s file
            f.write(f"zx02_{line}\n")
            for i in range(0, len(zx02_data), 16):
                f.write(
                    "\tdc.b "
                    + ", ".join(["${:02x}".format(byte) for byte in zx02_data[i : i + 16]])
                    + "\n"
                )