import sys

OFF_SYMBOLS, ON_SYMBOLS = ".", "#"

char_bytes = []
for l in sys.stdin:
    byte_bin = "".join(
        ["0" if c in OFF_SYMBOLS else "1" if c in ON_SYMBOLS else "" for c in l]
    )
    if len(byte_bin) > 0:
        byte_hex = hex(int(byte_bin, 2))[2:]
        char_bytes.append(byte_hex)
        if len(char_bytes) >= 8:
            print("\tdc.b", ", ".join(["$" + b for b in char_bytes]))
            char_bytes.clear()
