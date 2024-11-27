import sys

OFF_SYMBOLS, ON_SYMBOLS = ".", "#"

tank_up = """\
..####..\
...##...\
##.##.##\
########\
########\
########\
########\
##....##\
"""

tank_rotating_up = """\
..#..#..\
.##.###.\
########\
..######\
.#####..\
#####...\
.###....\
..##....\
"""

wall = [
    """\
........\
........\
........\
........\
........\
........\
........\
........\
""",
    """\
.#######\
.#######\
.#######\
........\
####.###\
####.###\
####.###\
........\
""",
    """\
.###.##.\
.#######\
..###.##\
........\
.##...##\
####.###\
####.##.\
.###.##.\
""",
    """\
..#.#.#.\
.#.#.#.#\
#.#.#.#.\
.#.#.#.#\
#.#.#.#.\
.#.#.#.#\
#.#.#.#.\
.#.#.#..\
""",
]

bullet_up = """\
........\
........\
...##...\
..####..\
..####..\
..####..\
........\
........\
"""

ammo = [
    """\
........\
...##...\
..####..\
...##...\
..####..\
..####..\
..####..\
........\
""",
    """\
........\
........\
...###..\
..#####.\
.######.\
.######.\
..####..\
........\
""",
    """\
........\
....#...\
...#....\
..####..\
.######.\
.######.\
..####..\
........\
""",
]

explosion = [
    """\
..#.....\
..##.#..\
.#######\
..#####.\
.#####..\
#######.\
..#.##..\
.....#..\
""",
]


def in_between(sprite_in):
    upper = "." * 32 + sprite_in[:32]
    lower = sprite_in[32:] + "." * 32
    return [lower, upper]


def rotate_left(sprite_in):
    rotated = ""
    for i in range(64):
        x = i % 8
        y = i // 8
        rotated += sprite_in[x * 8 + 7 - y]
    return rotated


def rotation(sprite_in):
    return [
        sprite_in,
        rotate_left(sprite_in),
        rotate_left(rotate_left(sprite_in)),
        rotate_left(rotate_left(rotate_left(sprite_in))),
    ]


sprites = []

sprites += wall
for e in [tank_up, bullet_up]:
    ib = in_between(e)
    sprites += rotation(e)
    sprites += rotation(ib[0])
    sprites += rotation(ib[1])
sprites += rotation(tank_rotating_up)
sprites += ammo
sprites += explosion


print("\nsprites\n")
for s in sprites:
    for l in [s[8 * i : 8 * (i + 1)] for i in range(8)]:
        print(l)
    print()

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
