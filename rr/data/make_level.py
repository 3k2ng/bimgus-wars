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

data_path = sys.argv[1]

with open(f"{data_path}/levels.txt", "r") as fi:
    levels = []
    cl = {"tile": [], "state": [], "position": [], "shots": []}
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
            cl["state"] += [ti[2]]
            cl["position"] += [ti[1] * 16 + ti[0]]
            cl["shots"] += ti[3:]
            i += 1
        elif ";" in l:
            compressed = []
            for _i in range(4):
                for _j in range(16):
                    byte = 0
                    for _k in range(4):
                        byte <<= 2
                        byte += cl["tile"][_i * 64 + _j * 4 + _k]
                    compressed.append(byte)
            cl["tile"] = compressed
            if len(cl["shots"]) < 8:
                cl["shots"] += [0] * (8 - len(cl["shots"]))
            shots = cl["shots"]
            cl["shots"] = [
                shots[0] + shots[1] * 4 + shots[2] * 16 + shots[3] * 64,
                shots[4] + shots[5] * 4 + shots[6] * 16 + shots[7] * 64,
            ]
            i = 0
            levels.append(cl)
            cl = {"tile": [], "state": [], "position": [], "shots": []}
        elif i < 25:  # enemy info
            ti = [int(c, 16) for c in l.split(" ")]
            cl["state"].append(ti[2])
            cl["position"].append(ti[1] * 16 + ti[0])
            i += 1
        else:
            print("Too many enemy info")

    with open(f"{data_path}/level_data.s", "w") as f:
        for level in levels:
            for i in range(4):
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
            if len(level["state"]) < 9:
                level["state"] += [0xFF] * (9 - len(level["state"]))
            if len(level["position"]) < 9:
                level["position"] += [0xFF] * (9 - len(level["position"]))
            f.write(
                "\tdc.b "
                + ", ".join(["${:02x}".format(b) for b in level["state"]])
                + "\n"
            )
            f.write(
                "\tdc.b "
                + ", ".join(["${:02x}".format(b) for b in level["position"]])
                + "\n"
            )
            f.write(
                "\tdc.b "
                + ", ".join(["${:02x}".format(b) for b in level["shots"]])
                + "\n"
            )
