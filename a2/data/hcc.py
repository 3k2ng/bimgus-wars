# custom compression
# RLE + LZW

# special character: $7f (b l)
#   => go back b characters
#   => fill the content with the next l characters

# cost: 3 bytes
#   => only use when more than 3 bytes is saved


def hcc_encode(char_map):
    encoded_map = [char_map[0]]
    back_i, i = 0, 1
    while i < len(char_map):
        b, l = 0, 1
        for j in range(back_i, i):
            if char_map[j] == char_map[i]:
                for prl in range(1, 256):
                    if (
                        i + prl >= len(char_map)
                        or char_map[i + prl] != char_map[j + prl]
                    ):
                        if prl > 3 and prl > l:
                            b, l = i - j, prl
                        break
        if l > 1:
            encoded_map += [0x7F, b, l]
        else:
            encoded_map += [char_map[i]]
        i += l
        back_i = max(i - 255, back_i)
    return encoded_map


def hcc_decode(encoded_map):
    decoded_map = []
    i = 0
    while i < len(encoded_map):
        if encoded_map[i] == 0x7F:
            back_i = len(decoded_map) - encoded_map[i + 1]
            l = encoded_map[i + 2]
            for j in range(l):
                decoded_map.append(decoded_map[back_i + j])
            i += 3
        else:
            decoded_map.append(encoded_map[i])
            i += 1
    return decoded_map
