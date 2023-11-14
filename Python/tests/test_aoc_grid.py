import unittest
from aoc.geometry import *
from aoc.grid import *

class TestGrid(unittest.TestCase):
    def test_create(self):
        grid:Grid2D = Grid2D()
        self.assertEqual(grid.default, '.')
        self.assertEqual(grid.rule, GridRule2D.ROOK)
        self.assertIsNone(grid.get_extent())
        grid = Grid2D(default='!', rule=GridRule2D.QUEEN)
        self.assertEqual(grid.default, '!')
        self.assertEqual(grid.rule, GridRule2D.QUEEN)
 
    def test_grid_get_set(self):
        grid:Grid2D = Grid2D()
        grid.set_value(Coord2D.origin(), 'A')
        v = grid.get_value(Coord2D.origin())
        self.assertEqual(v, 'A')
        v = grid.get_value(Coord2D(1,1))
        self.assertEqual(v, grid.default)
        grid.set_value(Coord2D(1,1), 9)
        v = grid.get_value(Coord2D(1,1))
        self.assertEqual(v, 9)
    
    def test_grid_clear(self):
        grid:Grid2D = Grid2D()
        grid.set_value(Coord2D(0,0), 'A')
        grid.set_value(Coord2D(1,1), 'B')
        grid.set_value(Coord2D(2,2), 'C')
        self.assertEqual(len(grid.get_coords()), 3)
        grid.clear(Coord2D(1,1))
        self.assertEqual(grid.get_value(Coord2D(1,1)), grid.default)
        self.assertEqual(len(grid.get_coords()), 2)
        grid.empty()
        self.assertEqual(len(grid.get_coords()), 0)

    def test_grid_extent(self):
        grid:Grid2D = Grid2D()
        grid.set_value(Coord2D(0,0), 'A')
        grid.set_value(Coord2D(1,1), 'B')
        grid.set_value(Coord2D(2,2), 'C')
        ext:Extent2D = grid.get_extent()
        self.assertEqual(ext.area(), 9)
        self.assertEqual(ext.max.x, 2)
 
    def test_grid_print(self):
        grid:Grid2D = Grid2D()
        grid.print()
        grid.set_value(Coord2D(0,0), 'A')
        grid.set_value(Coord2D(1,1), 'B')
        grid.set_value(Coord2D(2,2), 'C')
        print("Grid with 3 values:")
        grid.print()
        print("Grid inverted:")
        grid.print(invert_y=True)
        ov:dict[Coord2D,str] = dict()
        ov[Coord2D(2,0)] = "1"
        ov[Coord2D(1,1)] = "2"
        ov[Coord2D(0,2)] = "3"
        print("Grid with overlay:")
        grid.print(overlay=ov)

        