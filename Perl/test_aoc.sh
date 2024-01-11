#!/bin/sh

# Util
perl -Ilib t/aoc_util.t 
#prove -l t/aoc_util.t


# Geometry
#perl -Ilib t/aoc_geometry.t 
prove -l t/aoc_geometry.t

# Grid
#perl -Ilib t/aoc_grid.t 
prove -l t/aoc_grid.t
