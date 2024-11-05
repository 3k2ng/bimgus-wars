def run():
    pprefix = "./data/"
    pwrite = ""
    with open("./data/title_unc.txt") as f:
        for line in f:
            if line.startswith(";"): # new block!
                pwrite = line.strip().strip(";") # set the write prefix to the incoming line
                with open("./data/bin_list.bin", "a") as bl:
                    bl.write(f"{pwrite}\n")
            else: # block of data
                bytelist = line.strip().split() # list of bytes in this block
                temp_int_list = [] # clear the integer list
                for byte in bytelist: # for each string in this block,
                    temp_int_list.append(int(byte)) # turn into int
                with open(f"{pprefix}{pwrite}.bin", "ab") as fwrite: # write this list
                    fwrite.write(bytearray(temp_int_list))


if __name__ == "__main__":
    run()
