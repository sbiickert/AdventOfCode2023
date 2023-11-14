from enum import Enum
import math



# d8888b. d8888b. d888888b d8888b. .d888b. d8888b.
# 88  `8D 88  `8D   `88'   88  `8D VP  `8D 88  `8D
# 88oobY' 88   88    88    88oobY'    odD' 88   88
# 88`8b   88   88    88    88`8b    .88'   88   88
# 88 `88. 88  .8D   .88.   88 `88. j88.    88  .8D
# 88   YD Y8888D' Y888888P 88   YD 888888D Y8888D'

class RDir2D(Enum):
    CW = 'cw'
    CCW = 'ccw'


# d8888b. d888888b d8888b. .d888b. d8888b.
# 88  `8D   `88'   88  `8D VP  `8D 88  `8D
# 88   88    88    88oobY'    odD' 88   88
# 88   88    88    88`8b    .88'   88   88
# 88  .8D   .88.   88 `88. j88.    88  .8D
# Y8888D' Y888888P 88   YD 888888D Y8888D'

class Dir2D(Enum):
    NORTH = 'n'
    SOUTH = 's'
    EAST = 'e'
    WEST = 'w'
    NE = 'ne'
    NW = 'nw'
    SE = 'se'
    SW = 'sw'
    UP = 'n'    #alias for NORTH
    DOWN = 's'  #alias for SOUTH
    LEFT = 'w'  #alias for WEST
    RIGHT = 'e' #alias for EAST
    NONE = 'x'

    def turn_by(self, rotation_direction: RDir2D, steps: int) -> 'Dir2D':
        directions: list[Dir2D]
        directions = Dir2D.ordered(rotation_direction)
        ptr: int
        ptr = directions.index(self)
        if ptr == -1:
            return
        ptr = (ptr + steps) % len(directions)
        return directions[ptr]

    @classmethod
    def from_str(cls, value:str) ->'Dir2D':
        values: list[str]
        values = [member.value for member in Dir2D]

        if value in values:
            return cls(value)
        # Otherwise
        match value:
            case '^':
                return cls.UP
            case 'v':
                return cls.DOWN
            case '<':
                return cls.LEFT
            case '>':
                return cls.RIGHT
            case _:
                return cls.NONE

    @classmethod
    def ordered(cls, rdir:RDir2D) -> list['Dir2D']:
        if rdir == RDir2D.CW:
            return [Dir2D.NORTH, Dir2D.NE, Dir2D.EAST, Dir2D.SE,
                    Dir2D.SOUTH, Dir2D.SW, Dir2D.WEST, Dir2D.NW]
        return [Dir2D.NORTH, Dir2D.NW, Dir2D.WEST, Dir2D.SW,
                Dir2D.SOUTH, Dir2D.SE, Dir2D.EAST, Dir2D.NE]
       

#  .o88b.  .d88b.   .d88b.  d8888b. d8888b. .d888b. d8888b.
# d8P  Y8 .8P  Y8. .8P  Y8. 88  `8D 88  `8D VP  `8D 88  `8D
# 8P      88    88 88    88 88oobY' 88   88    odD' 88   88
# 8b      88    88 88    88 88`8b   88   88  .88'   88   88
# Y8b  d8 `8b  d8' `8b  d8' 88 `88. 88  .8D j88.    88  .8D
#  `Y88P'  `Y88P'   `Y88P'  88   YD Y8888D' 888888D Y8888D'

class Coord2D:
    def __init__(self, x:int, y:int) -> None:
        self.x: int
        self.y: int
        self.x = x
        self.y = y
    
    def row(self) -> int:
        return self.y
    
    def col(self) -> int:
        return self.x   
    
    def __str__(self) -> str:
        return f'[{self.x},{self.y}]'
    
    def __eq__(self, __value: 'Coord2D') -> bool:
        return self.x == __value.x and self.y == __value.y
    
    def __hash__(self) -> int:
        return self.x.__hash__() ^ self.y.__hash__()
    
    def __add__(self, other: 'Coord2D') -> 'Coord2D':
        return Coord2D(self.x + other.x, self.y + other.y)
    
    def __sub__(self, other: 'Coord2D') -> 'Coord2D':
        return Coord2D(self.x - other.x, self.y - other.y)
    
    def offset(self, direction: Dir2D) -> 'Coord2D':
        return self + Coord2D.offset_for_direction(direction)
    
    def distance_to(self, other: 'Coord2D') -> float:
        delta: Coord2D
        delta = self - other
        return math.sqrt(math.pow(delta.x, 2) + math.pow(delta.y, 2))

    def manhattan_distance_to(self, other: 'Coord2D') -> int:
        delta: Coord2D
        delta = self - other
        return abs(delta.x) + abs(delta.y)
    
    def copy(self) -> 'Coord2D':
        return Coord2D(self.x, self.y)
    
    @classmethod
    def origin(cls) -> 'Coord2D':
        return cls(0,0)
    
    @classmethod
    def offset_for_direction(cls, direction: Dir2D) -> 'Coord2D':
        match direction:
            case Dir2D.NORTH:
                return cls( 0, -1)
            case Dir2D.SOUTH:
                return cls( 0,  1)
            case Dir2D.EAST:
                return cls( 1,  0)
            case Dir2D.WEST:
                return cls(-1,  0)
            case Dir2D.NE:
                return cls( 1, -1)
            case Dir2D.NW:
                return cls(-1, -1)
            case Dir2D.SE:
                return cls( 1,  1)
            case Dir2D.SW:
                return cls(-1,  1)
            case _:
                return cls(0,0)
        

# d8888b.  .d88b.  .d8888. .d888b. d8888b.
# 88  `8D .8P  Y8. 88'  YP VP  `8D 88  `8D
# 88oodD' 88    88 `8bo.      odD' 88   88
# 88~~~   88    88   `Y8b.  .88'   88   88
# 88      `8b  d8' db   8D j88.    88  .8D
# 88       `Y88P'  `8888Y' 888888D Y8888D'

class Pos2D:
    def __init__(self, loc: Coord2D, dir: Dir2D) -> None:
        self.loc: Coord2D
        self.dir: Dir2D
        self.loc = loc
        self.dir = dir
    
    def __eq__(self, __value: 'Pos2D') -> bool:
        return self.loc == __value.loc and self.dir == __value.dir

    def __hash__(self) -> int:
        return self.loc.__hash__() ^ self.dir.__hash__()
    
    def turn(self, rotation_direction: Dir2D, amount:int = 90):
        steps: int
        steps = int(amount / 45)
        self.dir = self.dir.turn_by(rotation_direction, steps)
    
    def turned(self, rotation_direction: Dir2D, amount:int = 90) -> 'Pos2D':
        steps: int
        steps = int(amount / 45)
        return Pos2D(self.loc.copy(), self.dir.turn_by(rotation_direction, steps))


    @classmethod
    def origin(cls) -> 'Pos2D':
        return cls(Coord2D.origin(), Dir2D.NORTH)


# d88888b db    db d888888b d88888b d8b   db d888888b .d888b. d8888b.
# 88'     `8b  d8' `~~88~~' 88'     888o  88 `~~88~~' VP  `8D 88  `8D
# 88ooooo  `8bd8'     88    88ooooo 88V8o 88    88       odD' 88   88
# 88~~~~~  .dPYb.     88    88~~~~~ 88 V8o88    88     .88'   88   88
# 88.     .8P  Y8.    88    88.     88  V888    88    j88.    88  .8D
# Y88888P YP    YP    YP    Y88888P VP   V8P    YP    888888D Y8888D'

class Extent2D:
    def __init__(self, coords:list[Coord2D]) -> None:
        if len(coords) > 0:
            xmin = coords[0].x
            xmax = coords[0].x
            ymin = coords[0].y
            ymax = coords[0].y
            for i in range(1, len(coords)):
                xmin = min(xmin, coords[i].x)
                xmax = max(xmax, coords[i].x)
                ymin = min(ymin, coords[i].y)
                ymax = max(ymax, coords[i].y)
            self.min = Coord2D(xmin, ymin)
            self.max = Coord2D(xmax, ymax)
        else:
            self.min = Coord2D.origin()
            self.max = Coord2D.origin()
    
    def __eq__(self, __value: object) -> bool:
        return self.min == __value.min and self.max == __value.max

    def __hash__(self) -> int:
        return self.min.__hash__() ^ self.max.__hash__()
    
    def __str__(self) -> str:
        return f'[{self.min},{self.max}]'
    
    def width(self) -> int:
        return self.max.x - self.min.x + 1
    
    def height(self) -> int:
        return self.max.y - self.min.y + 1
    
    def area(self) -> int:
        return self.width() * self.height()
    
    def expanded_to_fit(self, coord: Coord2D) -> 'Extent2D':
        min_coord = Coord2D(min(self.min.x, coord.x), min(self.min.y, coord.y))
        max_coord = Coord2D(max(self.max.x, coord.x), max(self.max.y, coord.y))
        return Extent2D([min_coord, max_coord])

    def all_coords(self) -> list[Coord2D]:
        result: list[Coord2D]
        result = list()
        for x in range(self.min.x, self.max.x+1):
            for y in range(self.min.y, self.max.y+1):
                result.append(Coord2D(x,y))
        return result
    
    def contains(self, coord: Coord2D) -> bool:
        return self.min.x <= coord.x and \
            self.min.y <= coord.y and \
            coord.x <= self.max.x and \
            coord.y <= self.max.y

if __name__ == "__main__":
    print("aoc.geometry is a library.")
