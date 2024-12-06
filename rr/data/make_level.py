import sys

level_num = 0

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
    cl = {"tile": [], "state": [], "position": [], "type": [], "ammo": 0}
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
            cl["ammo"] += ti[3]
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
            i = 0
            levels.append(cl)
            cl = {"tile": [], "state": [], "position": [], "type": [], "ammo": 0}
        elif i < 25:  # enemy info
            ti = [int(c, 16) for c in l.split(" ")]
            cl["state"].append(ti[2])
            cl["position"].append(ti[1] * 16 + ti[0])
            cl["type"].append(ti[3])
            i += 1
        else:
            print("Too many enemy info")
    for level in levels:
        level_num += 1
        print(f"Level {level_num}: ", level)
        with open(f"{data_path}/level_{level_num}_data.bin", "wb") as f:
            if len(level["state"]) < 9:
                level["state"] += [0xFF] * (9 - len(level["state"]))
            if len(level["position"]) < 9:
                level["position"] += [0xFF] * (9 - len(level["position"]))
            if len(level["type"]) < 8:
                level["type"] += [0xFF] * (8 - len(level["type"]))
            f.write(bytearray(level["tile"]))
            f.write(bytearray(level["state"]))
            f.write(bytearray(level["position"]))
            f.write(bytearray([level["ammo"]]))
            f.write(bytearray(level["type"]))
    with open(f"{data_path}/level_num.txt", "w") as f:
        f.write(str(level_num))