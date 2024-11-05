def run():
    pprefix = "./data/"
    pwrite = ""
    temp_int_list = []
    with open("./data/title_unc.txt") as f:
        for line in f:
            if line.startswith(";"):
                pwrite = line.strip().strip(";")
                with open(f"{pprefix}{pwrite}.bin", "ab") as fwrite:
                    fwrite.write(bytearray(temp_int_list))
                temp_int_list = []
                continue
            bytelist = line.strip().split()
            for byte in bytelist:
                temp_int_list.append(int(byte))


if __name__ == "__main__":
    run()
