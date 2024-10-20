import sys

SYMBOLS_DICT = {".": "empty", "#": "wall", "@": "breakable", "%": "bush"}

SCREEN_CODE_DICT = {
    "empty": 0,
    "wall": 1,
    "breakable": 2,
    "bush": 3,
}

map_bytes = []
for l in sys.stdin:
    for c in l:
        if c in SYMBOLS_DICT.keys():
            map_bytes.append(SCREEN_CODE_DICT[SYMBOLS_DICT[c]])

    if len(map_bytes) >= 256:
        for i in range(16):
            print(
                "\tdc.b",
                ", ".join(["$" + hex(b)[2:] for b in map_bytes[16 * i : 16 * (i + 1)]]),
            )
