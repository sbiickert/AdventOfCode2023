#!/usr/bin/env python

import unittest
from aoc.geometry import *

class TestGeometry(unittest.TestCase):
    def test_direction(self):
        dir: Dir2D
        dir = Dir2D('n')
        self.assertEqual(dir, Dir2D.NORTH)
        dir = Dir2D.from_str('^')
        self.assertEqual(dir, Dir2D.UP)
        dir = Dir2D.from_str('#')
        self.assertEqual(dir, Dir2D.NONE)

    def test_direction_turn(self):
        dir1: Dir2D
        dir1 = Dir2D.NORTH
        dir2: Dir2D
        dir2 = dir1.turn_by(RDir2D.CW, 1)
        self.assertEqual(dir2, Dir2D.NE)
        dir2 = dir1.turn_by(RDir2D.CW, 3)
        self.assertEqual(dir2, Dir2D.SE)
        dir2 = dir1.turn_by(RDir2D.CCW, 2)
        self.assertEqual(dir2, Dir2D.WEST)
        dir2 = dir1.turn_by(RDir2D.CW, -1)
        self.assertEqual(dir2, Dir2D.NW)
        dir2 = dir1.turn_by(RDir2D.CW, -9)
        self.assertEqual(dir2, Dir2D.NW)
        dir2 = dir1.turn_by(RDir2D.CW, 8)
        self.assertEqual(dir2, Dir2D.NORTH)

    def test_coord_creation(self):
        p: Coord2D
        p = Coord2D(0, 1)
        self.assertEqual(p.x, 0)
        self.assertEqual(p.y, 1)
        self.assertEqual(p.row(), 1)
        self.assertEqual(p.col(), 0)
    
    def test_coord_equality(self):
        p1: Coord2D
        p2: Coord2D
        p3: Coord2D
        p1 = Coord2D.origin()
        p2 = Coord2D(0,0)
        self.assertEqual(p1,p2)
        p3 = Coord2D(10,5)
        self.assertNotEqual(p1, p3)

    def test_coord_hash(self):
        s: set[Coord2D]
        s = set()
        s.add(Coord2D.origin())
        s.add(Coord2D(1,1))
        self.assertEqual(len(s), 2)
        s.add(Coord2D.origin())
        self.assertEqual(len(s), 2)
       
    def test_coord_add(self):
        p1: Coord2D
        p2: Coord2D
        sum: Coord2D
        p1 = Coord2D(1,2)
        p2 = Coord2D(10, 10)
        sum = p1 + p2
        self.assertEqual(sum.x, 11)
        self.assertEqual(sum.y, 12)
    
    def test_coord_subtract(self):
        p1: Coord2D
        p2: Coord2D
        diff: Coord2D
        p1 = Coord2D(10, 10)
        p2 = Coord2D(1,2)
        diff = p1 - p2
        self.assertEqual(diff.x, 9)
        self.assertEqual(diff.y, 8)
    
    def test_offset(self):
        p: Coord2D
        p_off: Coord2D
        p = Coord2D.origin()
        p_off = p.offset(Dir2D.NORTH)
        self.assertEqual(p_off, Coord2D(0,-1))

    def test_distance(self):
        p1: Coord2D
        p2: Coord2D
        dist: float
        p1 = Coord2D.origin()
        p2 = Coord2D(5,5)
        dist = p1.distance_to(p2)
        self.assertAlmostEqual(dist, 7.0710678)

    def test_manhattan(self):
        p1: Coord2D
        p2: Coord2D
        dist: int
        p1 = Coord2D(5, 6)
        p2 = Coord2D(54, 13)
        dist = p1.manhattan_distance_to(p2)
        self.assertEqual(dist, 56)
    
    def test_pos_create(self):
        pos: Pos2D
        pos = Pos2D.origin()
        self.assertEqual(pos, Pos2D(Coord2D(0,0), Dir2D.NORTH))
        pos = Pos2D(Coord2D(1,2), Dir2D.EAST)
        self.assertEqual(pos.loc, Coord2D(1,2))
        self.assertEqual(pos.dir, Dir2D.EAST)
    
    def test_pos_hash(self):
        s: set[Pos2D]
        s = set()
        s.add(Pos2D.origin())
        s.add(Pos2D(Coord2D(1,2), Dir2D.NE))
        self.assertEqual(len(s), 2)
        s.add(Pos2D.origin())
        self.assertEqual(len(s), 2)

    def test_pos_turn(self):
        pos1: Pos2D
        pos1 = Pos2D.origin()
        pos1.turn(RDir2D.CCW, 135)
        self.assertEqual(pos1.dir, Dir2D.SW)
        pos2: Pos2D
        pos2 = pos1.turned(RDir2D.CCW, 45)
        self.assertEqual(pos2.dir, Dir2D.SOUTH)
        self.assertFalse(pos1 is pos2)
    
    def test_extent_create(self):
        ext: Extent2D
        ext = Extent2D([Coord2D(1,4), Coord2D(3,2)])
        self.assertEqual(ext.min, Coord2D(1,2))
        self.assertEqual(ext.max, Coord2D(3,4))

    def test_extent_dimensions(self):
        ext: Extent2D
        ext = Extent2D([Coord2D(1,6), Coord2D(3,2)])
        self.assertEqual(ext.width(), 3)
        self.assertEqual(ext.height(), 5)
        self.assertEqual(ext.area(), 15)

    def test_extent_expansion(self):
        ext1: Extent2D
        ext1 = Extent2D([Coord2D(1,6), Coord2D(3,2)])
        ext2: Extent2D
        ext2 = ext1.expanded_to_fit(Coord2D.origin())
        self.assertEqual(ext2.min, Coord2D.origin())
        self.assertNotEqual(ext1, ext2)
        ext2 = ext1.expanded_to_fit(Coord2D(2,2))
        self.assertEqual(ext1, ext2)

    def test_extent_contains(self):
        ext = Extent2D([Coord2D(0,0), Coord2D(2,2)])
        self.assertFalse(ext.contains(Coord2D(-1,0)))
        self.assertFalse(ext.contains(Coord2D(-1,-1)))
        self.assertFalse(ext.contains(Coord2D(0,-1)))
        self.assertFalse(ext.contains(Coord2D(2,3)))
        self.assertFalse(ext.contains(Coord2D(3,2)))
        self.assertTrue(ext.contains(Coord2D(1,1)))

if __name__ == '__main__':
    unittest.main()