import sys
import imageio.v3 as iio
import numpy as np

EMPTY_CODE = 0
WHITE_CODE = 1
RED_CODE = 2
GREEN_CODE = 5

TILE_SIZE = 8
SCREEN_WIDTH = 22
SCREEN_HEIGHT = 23
TOTAL_SCREEN_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT

TITLE_TEXT = "BIMGUSWARSURMOM2024"
OFF_SYMBOLS, ON_SYMBOLS = ".", "#"

INPUT_IMAGE_NAME = sys.argv[1]
OUTPUT_NAME = sys.argv[2]

title_card = iio.imread(INPUT_IMAGE_NAME)
bit_arr = np.array(
    [
        [
            (
                EMPTY_CODE
                if p[0] == 0 and p[1] == 0 and p[2] == 0
                else (
                    RED_CODE
                    if p[0] == 172 and p[1] == 50 and p[2] == 50
                    else (
                        GREEN_CODE
                        if p[0] == 106 and p[1] == 190 and p[2] == 48
                        else WHITE_CODE
                    )
                )
            )
            for p in r
        ]
        for r in list(title_card)
    ]
).flatten()

data2count = {}
data2id = {
    "########\n##.....#\n#.#....#\n#..#...#\n#...#..#\n#....#.#\n#.....##\n########": -1,
    "........\n........\n........\n........\n........\n........\n........\n........": 224,
    "####....\n####....\n####....\n####....\n####....\n####....\n####....\n####....": 225,
}

uc = 0
char_map = [0] * TOTAL_SCREEN_SIZE
color_map = [1] * TOTAL_SCREEN_SIZE

for y in range(23):
    for x in range(22):
        i = x * 8 + y * 64 * 22
        rows = [bit_arr[(i + j * 22 * 8) : (i + j * 22 * 8) + 8] for j in range(8)]
        vismap = "\n".join(
            ["".join(["." if e == 0 else "#" for e in row]) for row in rows]
        )
        if vismap in data2count.keys():
            data2count[vismap] += 1
        else:
            data2count[vismap] = 1
        if vismap not in data2id.keys():
            data2id[vismap] = uc
            uc += 1
        char_map[y * 22 + x] = data2id[vismap]
        color_map[y * 22 + x] = max(np.array(rows).flatten())

color_map = [max(1, i) for i in color_map]

id2data = {}
for data in data2id.keys():
    id = data2id[data]
    id2data[id] = data

with open(f"./{OUTPUT_NAME}_char_set.s", "w") as f:
    f.write(f"TITLE_CHAR_SET_SIZE = {uc * 8}\n")
    for i in range(uc):
        byte_bin = [
            int(
                "".join(
                    [
                        "0" if c in OFF_SYMBOLS else "1" if c in ON_SYMBOLS else ""
                        for c in r
                    ]
                ),
                2,
            )
            for r in id2data[i].split("\n")
        ]
        f.write(
            "\tdc.b " + ", ".join(["${:02x}".format(byte) for byte in byte_bin]) + "\n"
        )

text2id = {}
for c in TITLE_TEXT:
    if ord("A") <= ord(c) <= ord("Z"):
        text2id[c] = ord(c) - ord("A") + 129
    elif ord("0") <= ord(c) <= ord("9"):
        text2id[c] = ord(c) - ord("0") + 176

with open(f"./{OUTPUT_NAME}_char_map.s", "w") as f:
    j = 0
    for i in range(23):
        hex_bytes = []
        for byte in char_map[i * 22 : (i + 1) * 22]:
            if byte < 0:
                hex_bytes.append(text2id[TITLE_TEXT[j]])
                j += 1
            else:
                hex_bytes.append(byte)

        f.write(
            "\tdc.b " + ", ".join(["${:02x}".format(byte) for byte in hex_bytes]) + "\n"
        )

with open(f"./{OUTPUT_NAME}_color_map.s", "w") as f:
    for i in range(23):
        f.write(
            "\tdc.b "
            + ", ".join(
                ["${:02x}".format(byte) for byte in color_map[i * 22 : (i + 1) * 22]]
            )
            + "\n"
        )
