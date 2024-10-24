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


def gen_data(input_image):
    title_card = iio.imread(input_image)
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

    id2data = {}
    for data in data2id.keys():
        id = data2id[data]
        id2data[id] = data

    char_set = []
    for i in range(uc):
        char_set += [
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

    text2id = {}
    for c in TITLE_TEXT:
        if ord("A") <= ord(c) <= ord("Z"):
            text2id[c] = ord(c) - ord("A") + 129
        elif ord("0") <= ord(c) <= ord("9"):
            text2id[c] = ord(c) - ord("0") + 176

    title_text_index = 0
    for i, byte in enumerate(char_map):
        if byte < 0:
            char_map[i] = text2id[TITLE_TEXT[title_text_index]]
            title_text_index += 1

    return {
        "char_set": char_set,
        "char_map": char_map,
        "color_map": color_map,
    }
