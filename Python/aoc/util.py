def signed_to_unsigned(n, byte_count): 
  return int.from_bytes(n.to_bytes(byte_count, 'little', signed=True), 'little', signed=False)

def unsigned_to_signed(n, byte_count): 
  return int.from_bytes(n.to_bytes(byte_count, 'little', signed=False), 'little', signed=True)

        
if __name__ == "__main__":
    print("aoc.util is a library.")
