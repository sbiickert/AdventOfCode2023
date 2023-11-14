from aoc.geometry import *
from enum import Enum

#  d888b  d8888b. d888888b d8888b. d8888b. db    db db      d88888b .d888b. d8888b.
# 88' Y8b 88  `8D   `88'   88  `8D 88  `8D 88    88 88      88'     VP  `8D 88  `8D
# 88      88oobY'    88    88   88 88oobY' 88    88 88      88ooooo    odD' 88   88
# 88  ooo 88`8b      88    88   88 88`8b   88    88 88      88~~~~~  .88'   88   88
# 88. ~8~ 88 `88.   .88.   88  .8D 88 `88. 88b  d88 88booo. 88.     j88.    88  .8D
#  Y888P  88   YD Y888888P Y8888D' 88   YD ~Y8888P' Y88888P Y88888P 888888D Y8888D'

class GridRule2D(Enum):
    ROOK = 'rook'
    BISHOP = 'bishop'
    QUEEN = 'queen'

    def offsets(self) -> list[Coord2D]:
        result: list[Coord2D]
        result = list()
        if self in [GridRule2D.ROOK, GridRule2D.QUEEN]:
            result.append(Coord2D.offset_for_direction(Dir2D.NORTH))
            result.append(Coord2D.offset_for_direction(Dir2D.EAST))
            result.append(Coord2D.offset_for_direction(Dir2D.SOUTH))
            result.append(Coord2D.offset_for_direction(Dir2D.WEST))
        if self in [GridRule2D.BISHOP, GridRule2D.QUEEN]:
            result.append(Coord2D.offset_for_direction(Dir2D.NW))
            result.append(Coord2D.offset_for_direction(Dir2D.NE))
            result.append(Coord2D.offset_for_direction(Dir2D.SE))
            result.append(Coord2D.offset_for_direction(Dir2D.SW))
        return result


#  d888b  d8888b. d888888b d8888b. .d888b. d8888b.
# 88' Y8b 88  `8D   `88'   88  `8D VP  `8D 88  `8D
# 88      88oobY'    88    88   88    odD' 88   88
# 88  ooo 88`8b      88    88   88  .88'   88   88
# 88. ~8~ 88 `88.   .88.   88  .8D j88.    88  .8D
#  Y888P  88   YD Y888888P Y8888D' 888888D Y8888D'

class Grid2D:
    def __init__(self, default: str = '.', rule: GridRule2D = GridRule2D.ROOK) -> None:
        self._data: dict[Coord2D,any]
        self._data = dict()
        self.rule: GridRule2D
        self.rule = rule
        self.default = default
        self._extent: Extent2D
        self._extent = None
    
    def get_value(self, coord: Coord2D) -> any:
        return self._data.get(coord, self.default)
    
    def set_value(self, coord: Coord2D, value:any) -> None:
        self._data[coord] = value
        if self._extent is None:
            self._extent = Extent2D([coord])
        else:
            self._extent = self._extent.expanded_to_fit(coord)

    def clear(self, coord: Coord2D) -> None:
        del self._data[coord]
        self._extent = None

    def empty(self) -> None:
        self._data.clear()
        self._extent = None

    def get_extent(self) -> Extent2D:
        if self._extent is None:
            coords:list[Coord2D] = self.get_coords()
            if len(coords) > 0:
                self._extent = Extent2D(coords)
        return self._extent
    
    def get_coords(self, adjacent_to:Coord2D=None, with_value:any=None) -> list[Coord2D]:
        coords: list[Coord2D]
        if adjacent_to is None:
            coords = self._data.keys()
        else:
            offsets: list[Coord2D]
            offsets = self.rule.offsets()
            coords = list()
            for offset in offsets:
                coords.append(adjacent_to + offset)
        if with_value is not None:
            coords = list(filter(lambda coord: (self._data[coord] == with_value), coords))
        return coords
    
    def print(self, invert_y:bool=False, overlay:dict[Coord2D,str]=None):
        ext:Extent2D = self.get_extent()
        if ext is None:
            print("Empty grid")
            return
        
        start_row: int = ext.min.y
        end_row:int = ext.max.y
        step:int = 1

        if invert_y:
            temp = start_row
            start_row = end_row
            end_row = temp
            step = -1

        row:int = start_row
        while True:
            line:str = ''
            for col in range(ext.min.x, ext.max.x):
                c:Coord2D = Coord2D(col,row)
                value:str
                if overlay is not None and overlay.get(c) is not None:
                    value = overlay[c]
                else:
                    value = str(self.get_value(c))
                line = line + value
            print(line)
            if row == end_row:
                break
            row += step
