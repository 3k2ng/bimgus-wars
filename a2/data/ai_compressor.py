import struct

def rle_compress(data):
    """Compress data using pure Run-Length Encoding (RLE)."""
    compressed = []
    i = 0

    while i < len(data):
        value = data[i]
        count = 1

        # Count consecutive occurrences of the same value (up to 255)
        while i + count < len(data) and data[i + count] == value and count < 255:
            count += 1

        # Store (value, count) pair
        compressed.append((value, count))
        i += count

    return compressed

def rle_decompress(compressed):
    """Decompress data compressed with RLE."""
    decompressed = []
    for value, count in compressed:
        decompressed.extend([value] * count)

    return decompressed

def write_rle_to_bin(compressed, output_file):
    """Write compressed RLE data to a .bin file."""
    with open(output_file, 'wb') as f:
        for value, count in compressed:
            f.write(struct.pack('BB', value, count))

def read_rle_from_bin(input_file):
    """Read compressed RLE data from a .bin file."""
    compressed = []
    with open(input_file, 'rb') as f:
        while True:
            entry = f.read(2)
            if not entry:
                break
            value, count = struct.unpack('BB', entry)
            compressed.append((value, count))

    return compressed

def main(input_file, compressed_file, decompressed_file):
    """Main function to compress and decompress binary data."""
    # Read input binary file
    with open(input_file, 'rb') as f:
        data = list(f.read())

    # Compress the data using RLE
    compressed = rle_compress(data)
    write_rle_to_bin(compressed, compressed_file)

    # Check sizes
    original_size = len(data)
    compressed_size = len(compressed) * 2  # Each entry is 2 bytes

    print(f"Original size: {original_size} bytes")
    print(f"Compressed size: {compressed_size} bytes")

    if compressed_size < original_size:
        print("Compression successful!")

        # Decompress to verify
        compressed_data = read_rle_from_bin(compressed_file)
        decompressed = rle_decompress(compressed_data)

        # Write decompressed data to a file
        with open(decompressed_file, 'wb') as f:
            f.write(bytearray(decompressed))

        print("Decompression completed and verified!")
    else:
        print("Compression not effective. Skipping decompression.")

# Example usage
if __name__ == "__main__":
    # input_file = "input.bin"            # Replace with your input file
    input_file = "./char_map.bin"            # Replace with your input file
    compressed_file = "compressed.bin"  # Output compressed file
    decompressed_file = "decompressed.bin"  # Output decompressed file

    main(input_file, compressed_file, decompressed_file)
