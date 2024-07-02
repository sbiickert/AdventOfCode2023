#!/usr/bin/env ruby

require 'minitest/autorun'
require 'grid'
require 'util'

class TestGrid < Minitest::Test

	def test_grid
		g = Grid.new()
		assert_equal(:ROOK, g.rule)
		assert_equal('.', g.default)
		assert_nil(g.extent)
		
		g.set(Coord.new(1,1), 'A')
		g.set(Coord.new(2,2), 'B')
		g.set(Coord.new(4,4), 'D')
		
		g.set(Coord.new(1,4), {:glyph => 'E', 'type' => 'Elf', 'HP' => 100})
		g.set(Coord.new(2,4), {:glyph => 'G', 'type' => 'Goblin', 'HP' => 95})
		g.set(Coord.new(3,4), BasicGlyph.new('S'))
		
		#g.print
		
		assert_equal('A', g.get(Coord.new(1,1)))
		assert_equal('B', g.get(Coord.new(2,2)))
		assert_equal(g.default, g.get(Coord.new(3,3)))
		assert_equal('D', g.get(Coord.new(4,4)))
		
		assert_equal('E', g.get_s(Coord.new(1,4)))
		assert_equal('G', g.get_s(Coord.new(2,4)))
		assert_equal('S', g.get_s(Coord.new(3,4)))
		
		ext = g.extent
		assert_equal(Coord.new(1,1), ext.nw)
		assert_equal(Coord.new(4,4), ext.se)
		
		all = g.coords
		assert_equal(6, all.length) # Coords with 
		matching = g.coords('B')
		assert_equal(1, matching.length)
		assert_equal(Coord.new(2,2), matching.first)
		
		g.set(Coord.new(3,3), 'B')
		hist = g.histogram
		assert(hist['A'] == 1 && hist['B'] == 2 && hist['.'] == 0)
		hist = g.histogram(true)
		assert(hist['A'] == 1 && hist['B'] == 2 && hist['.'] == 9)
		
		neighbors = g.neighbors(Coord.new(2,2))
		assert_equal(4, neighbors.length)
		assert_equal([Coord.new(2,1),Coord.new(3,2),Coord.new(2,3),Coord.new(1,2)], neighbors)
		
		g_str = g.to_s
		assert_equal("A...\n.B..\n..B.\nEGSD\n", g_str)
		g_str = g.to_s(nil,true)
		assert_equal("EGSD\n..B.\n.B..\nA...\n", g_str)
		
		markers = {Coord.new(4,1) => '*'}
		g_str = g.to_s(markers)
		assert_equal("A..*\n.B..\n..B.\nEGSD\n", g_str)
		
		g.clear(Coord.new(3,3))
		assert_equal(g.get(Coord.new(3,3)), g.default)
		g.set(Coord.new(100,100), 'X')
		big_ext = g.extent
		assert_equal(Coord.new(100,100), big_ext.se)
		g.clear(Coord.new(100,100), true)
		small_ext = g.extent
		assert_equal(ext, small_ext)
	end
	
	def test_grid_fill
	  g = Grid.new()
    defn = ['X.....',
            '.XXXX.',
            '.X..X.',
            '.X.XX.',
            '.XXX..',
            '.....X']
    g.load(defn)
    #g.print
    c = Coord.new(0,0)
    g.flood_fill(c, 'A') # No effect, (0,0) is not default '.'
    assert_equal(g.get(c), 'X')
    #g.print
    c = Coord.new(2,2)
    spill = g.flood_fill(c, 'B') # Fill center, return false (no spill)
    refute(spill)
    #g.print
    c = Coord.new(0,1)
    spill = g.flood_fill(c, 'C') # Fill outside, return true (spill)
    assert(spill)
    #g.print
	end
	
	def test_grid_load 
		input_path = '../Input';
		input_file = 'day00_test.txt';
		input = Util.read_input("#{input_path}/#{input_file}", false)
		
		g = Grid.new
		g.load(input)
		assert_equal("G0, L0\nG0, L1\nG0, L2\nG1, L0\nG1, L1\nG2, L0\nG2, L1\nG2, L2\n", g.to_s)
		assert_equal('2', g.get_s(Coord.new(5,2)))
	end
end

class BasicGlyph
	include GridGlyph
	
	def initialize(glyph)
		@glyph = glyph
	end
end