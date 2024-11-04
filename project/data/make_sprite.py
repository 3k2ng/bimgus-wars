import sys

OFF_SYMBOLS, ON_SYMBOLS = ".", "#"

tank_n = """\
..####..\
...##...\
##.##.##\
########\
########\
########\
########\
##....##\
"""

tank_nw = """\
..#..#..\
.##.###.\
########\
..######\
.#####..\
#####...\
.###....\
..##....\
"""


def make_ib(sprite_in, is_vertical):
    if is_vertical:
        upper = "." * 32 + sprite_in[:32]
        lower = sprite_in[32:] + "." * 32
        return [upper, lower]
    else:
        left = "".join(["." * 4 + sprite_in[8 * i : 8 * i + 4] for i in range(8)])
        right = "".join(
            [sprite_in[8 * i + 4 : 8 * (i + 1)] + "." * 4 for i in range(8)]
        )
        return [left, right]


def flip_diag(sprite_in, nw_axis):
    flipped = ""
    for i in range(64):
        x = i % 8
        y = i // 8
        if nw_axis:
            flipped += sprite_in[8 * x + y]
        else:
            flipped += sprite_in[8 * (7 - x) + 7 - y]
    return flipped


def flip_card(sprite_in, n_axis):
    flipped = ""
    for i in range(64):
        x = i % 8
        y = i // 8
        if n_axis:
            flipped += sprite_in[7 - x + y * 8]
        else:
            flipped += sprite_in[x + (7 - y) * 8]
    return flipped


sprites = []

for i in range(4):
    if i == 0:
        sprites += [tank_n]
        sprites += make_ib(tank_n, True)
        sprites += [tank_nw]
    elif i % 2 == 0:
        sprites += [flip_diag(sprites[4 * i - 4], False)]
        sprites += make_ib(sprites[4 * i], True)
        sprites += [flip_card(sprites[4 * i - 1], True)]
    else:
        sprites += [flip_diag(sprites[4 * i - 4], True)]
        sprites += make_ib(sprites[4 * i], False)
        sprites += [flip_card(sprites[4 * i - 1], False)]


data_path = sys.argv[1]

with open(f"{data_path}/sprite_data.s", "w") as f:
    for s in sprites:
        char_bytes = [
            int(
                "".join(
                    [
                        "0" if c in OFF_SYMBOLS else "1" if c in ON_SYMBOLS else ""
                        for c in s[8 * i : 8 * (i + 1)]
                    ]
                ),
                2,
            )
            for i in range(8)
        ]
        f.write(
            "\tdc.b "
            + ", ".join(["${:02x}".format(byte) for byte in char_bytes])
            + "\n"
        )