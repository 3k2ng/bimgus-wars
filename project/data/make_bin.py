def run():
    with open("./title_unc.txt") as f:
        for line in f:
            if line.startswith(";"): continue
            bytelist = line.split(" ")
            print(len(bytelist))


if __name__ == "__main__":
    run()
