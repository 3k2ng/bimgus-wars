import struct
import sys
import os

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

import struct

def write_rle_to_bin(compressed, output_file):
    """Write compressed RLE data to a .bin file."""
    with open(output_file, 'wb') as f:
        for value, count in compressed:
            if count == 0x7F:
                # If count is exactly 0x7F, write (value, count - 1) and (value, 1)
                f.write(struct.pack('BB', value, count - 1))
                f.write(struct.pack('BB', value, 1))
            elif count > 0x7F:
                # If count is greater than 0x7F, handle splitting
                var = count // 0x7F  # Calculate how many full 0x7F counts we have
                remainder = count % 0x7F  # Calculate any remaining count

                # Write full 0x7F counts
                for _ in range(var):
                    
                    # original code
                    # f.write(struct.pack('BB', value, 0x7F))
                    # Manually updated code to handle base case in the decoder
                    f.write(struct.pack('BB', value, 0x7E))
                    f.write(struct.pack('BB', value, 0x01))
                
                # Write the remaining count, if any
                if remainder > 0:
                    f.write(struct.pack('BB', value, remainder))
            else:
                # For counts less than 0x7F, just write the value and count
                f.write(struct.pack('BB', value, count))

        # Only add terminator sequence after all data has been written
        f.write(struct.pack('BB', 0, 0x7F))  # Value doesn't matter, count of 0x7F signals end


def process_file(input_file, output_file):
    """Compress the input file using RLE and save it to output_file."""
    with open(input_file, 'rb') as f:
        data = list(f.read())

    compressed = rle_compress(data)
    write_rle_to_bin(compressed, output_file)

    original_size = len(data)
    compressed_size = len(compressed) * 2  # Each (value, count) pair is 2 bytes

    print(f"{input_file} -> {output_file}")
    print(f"Original size: {original_size} bytes, Compressed size: {compressed_size} bytes")
    if compressed_size < original_size:
        print("Compression successful!\n")
    else:
        print("Compression not effective.\n")

def main(input_files, output_dir):
    """Process multiple files and save their RLE-compressed versions."""
    for input_file in input_files:
        # Extract filename without extension
        filename = os.path.splitext(os.path.basename(input_file))[0]
        output_file = os.path.join(output_dir, f"{filename}_rle.bin")

        process_file(input_file, output_file)

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python script.py char_map.bin char_set.bin color_map.bin output_dir/")
        sys.exit(1)

    # Collect input files and output directory from command-line arguments
    input_files = sys.argv[1:4]
    output_dir = sys.argv[4]

    main(input_files, output_dir)
