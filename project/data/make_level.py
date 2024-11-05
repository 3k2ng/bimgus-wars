import sys

EMPTY_TILE = 0
WALL_TILE = 1
CRACK_TILE = 2
BUSH_TILE = 3

tile_map = {
    ".": EMPTY_TILE,
    "#": WALL_TILE,
    "@": CRACK_TILE,
    "%": BUSH_TILE,
}

tank_symbols = "^<V>"

data_path = sys.argv[1]

with open(f"{data_path}/levels.txt", "r") as fi:
    levels = []
    cl = {"tile": [], "player": [], "enemy": [], "shots": []}
    i = 0
    for l in fi:
        l = l.strip()
        if l == "":
            continue
        if i < 16:
            for c in l:
                if c in tile_map.keys():
                    cl["tile"].append(tile_map[c])
            i += 1
        elif i < 17:  # player info
            ti = [int(c, 16) for c in l.split(" ")]
            cl["player"] += [ti[0], ti[1], ti[2]]
            cl["shots"] += ti[3:]
            i += 1
        elif ";" in l:
            i = 0
            levels.append(cl)
            cl = {"tile": [], "player": [], "enemy": [], "shots": []}
        elif i < 25:  # enemy info
            ti = [int(c, 16) for c in l.split(" ")]
            cl["enemy"].append([ti[0], ti[1], ti[2]])
            i += 1
        else:
            print("Too many enemy info")
    print(levels)
    with open(f"{data_path}/level_data.s", "w") as f:
        for level in levels:
            for i in range(16):
                f.write(
                    "\tdc.b "
                    + ", ".join(
                        [
                            "${:02x}".format(b)
                            for b in level["tile"][16 * i : 16 * (i + 1)]
                        ]
                    )
                    + "\n"
                )
            f.write(
                "\tdc.b "
                + ", ".join(["${:02x}".format(b) for b in level["player"]])
                + "\n"
            )
            for enemy in level["enemy"]:
                f.write(
                    "\tdc.b " + ", ".join(["${:02x}".format(b) for b in enemy]) + "\n"
                )
            f.write("\tdc.b $ff\n")
            f.write(
                "\tdc.b "
                + ", ".join(["${:02x}".format(b) for b in level["shots"] + [0xFF]])
                + "\n"
            )
