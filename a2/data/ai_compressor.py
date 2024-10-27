from collections import defaultdict

def build_dictionary(data, max_dict_size=256):
    """Build a dictionary of the most common patterns in the data."""
    pattern_count = defaultdict(int)

    # Collect all two-byte patterns and their frequencies
    for i in range(len(data) - 1):
        pattern = (data[i], data[i + 1])
        pattern_count[pattern] += 1

    # Sort patterns by frequency and keep only the most frequent ones
    sorted_patterns = sorted(pattern_count.items(), key=lambda x: -x[1])
    dictionary = {pattern[0]: idx for idx, pattern in enumerate(sorted_patterns[:max_dict_size])}
    
    return dictionary

def compress(data):
    """Compress data using RLE and Dictionary encoding."""
    dictionary = build_dictionary(data)
    compressed = []
    
    i = 0
    while i < len(data):
        # Check if the next two-byte pattern is in the dictionary
        if i < len(data) - 1 and (data[i], data[i + 1]) in dictionary:
            code = dictionary[(data[i], data[i + 1])]
            compressed.append((code, 1))  # Store dictionary code and count 1
            i += 2  # Skip the pattern
        else:
            # Apply RLE for repeated values
            value = data[i]
            count = 1
            while i + count < len(data) and data[i + count] == value:
                count += 1
            compressed.append((value, count))  # Store value and count
            i += count  # Skip the repeated values

    return compressed, dictionary

def decompress(compressed, dictionary):
    """Decompress data using the provided dictionary and compressed data."""
    decompressed = []
    
    # Reverse the dictionary to map codes back to patterns
    reverse_dict = {v: k for k, v in dictionary.items()}
    
    for value, count in compressed:
        if value in reverse_dict:  # If it's a dictionary code
            pattern = reverse_dict[value]
            decompressed.extend(pattern * count)
        else:  # Regular RLE entry
            decompressed.extend([value] * count)

    return decompressed

# Example usage
data = [0xAA, 0xBB, 0xBB, 0xBB, 0xAA, 0xBB, 0xBB, 0xBB, 0xAA]
compressed, dictionary = compress(data)
print("Compressed:", compressed)
print("Dictionary:", dictionary)

decompressed = decompress(compressed, dictionary)
print("Decompressed:\n", decompressed)
print("Data:\n", data)
