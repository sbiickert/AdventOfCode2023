from typing import Optional

INPUT_DIR = '../Input'

def build_full_name(name: str):
    return f'{INPUT_DIR}/{name}'

def read_input_file(name: str, remove_empty_lines: bool) -> list[str]:
    full_input_name = build_full_name(name)
    print(f'Input: {full_input_name}')
    with open(full_input_name, 'r') as file:
        content = file.read()
        input = content.splitlines()
    if remove_empty_lines:
        input = list(filter(lambda line: (line != ''), input))
    return input

def read_grouped_input_file(name: str) -> list[list[str]]:
    input = read_input_file(name, False)
    group = []
    groups = []
    for line in input:
        if line != '':
            group.append(line)
        else:
            groups.append(group)
            group = []
    groups.append(group)
    return groups

def read_grouped_input_file(name: str, index: int) -> Optional[list[str]]:
    all_groups = read_grouped_input_file(name)
    if index >= 0 and index < len(all_groups):
        return all_groups[index]
    return None

        
if __name__ == "__main__":
    print("aoc.input is a library.")
