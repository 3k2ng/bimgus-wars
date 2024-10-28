import sys

# custom compression
# RLE + LZW

# special character: $7E (b l)
#   => go back b characters
#   => fill the content with the next l characters

# cost: 3 bytes
#   => only use when more than 3 bytes is saved


def umc(in_data):
    out_data = [in_data[0]]
    back_i, i = 0, 1
    while i < len(in_data):
        b, l = 0, 1
        for j in range(back_i, i):
            if in_data[j] == in_data[i]:
                for prl in range(1, 256):
                    if i + prl >= len(in_data) or in_data[i + prl] != in_data[j + prl]:
                        if prl > 3 and prl > l:
                            b, l = i - j, prl
                        break
        if l > 1:
            out_data += [0x7E, b, l]
        else:
            out_data += [in_data[i]]
        i += l
        back_i = max(i - 255, back_i)
    out_data += [0x7F]
    return out_data


in_file = sys.argv[1]
out_file = sys.argv[2]

with open(out_file, "wb") as f:
    with open(in_file, "rb") as fi:
        f.write(bytearray(umc(fi.read())))
