#!/usr/bin/env ruby

require 'minitest/autorun'
require 'grid'

class TestGrid < Minitest::Test

	def test_grid
		g = Grid.new()
		assert_equal(:ROOK, g.rule)
		assert_equal('.', g.default)
		assert_nil(g.extent)
		
		g.set(Coord.new(1,1), 'A')
		g.set(Coord.new(2,2), 'B')
		g.set(Coord.new(4,4), 'D')
	end
end