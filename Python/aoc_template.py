import aoc.input

IN_FILE = 'day<##>_test.txt'
#IN_FILE = 'day<##>_challenge.txt'

def solve_part_one():
    print(f'Part One: DESCRIPTION')
    result = 0
    print(f'Part One Solution: {result}')

def solve_part_two():
    print(f'Part Two: DESCRIPTION')
    result = 0
    print(f'Part Two Solution: {result}')

def main(input_file: str):
    print(f'Advent of Code 2023, Day <##>: <##>')
    input: list[str]
    input = aoc.input.read_input_file(input_file, True)
    
    # Transform input here
    
    solve_part_one()
    solve_part_two()

if __name__ == "__main__":
    main(IN_FILE)
