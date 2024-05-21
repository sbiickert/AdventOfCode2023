#!/usr/bin/env ruby

require 'minitest/autorun'
require 'geometry'
require 'util'

class TestGeometry < Minitest::Test

	def test_coord
		# To String
		coord1 = Coord.new(10,30)
		c_str = coord1.to_s
		assert_equal('[10,30]', c_str)
		
		# From String
		coord2 = Coord.from_s(c_str)
		assert_equal(coord1, coord2)
		
		# Equality
		coord3 = Coord.new(10,30)
		assert_equal(coord1, coord3)
		coord4 = Coord.new(5,20)
		refute_equal(coord1, coord4)
		
		# Origin
		origin = Coord.origin
		assert(origin.x == 0 && origin.y == 0)
		
		# Delta
		delta = coord1.delta(coord4)
		assert(delta.x == -5 && delta.y == -10)
		
		# Distance
		dist = coord1.distance(coord4)
		assert(Util.approx_equal?(dist, 11.1803398874989))
		md = coord1.manhattan(coord4)
		assert_equal(15, md)
		
		# Offsets
		assert_equal(Coord.new(0,-1), origin.offset(:N))
		assert_equal(Coord.new(0,-1), origin.offset('N'))
		assert_equal(Coord.new(-1,0), origin.offset('<'))
		assert_equal(Coord.origin, origin.offset('?'))
		
		# Adjacency
		coord11 = Coord.new(1,1)
		refute(origin.adjacent?(coord11)) # :ROOK
		assert(origin.adjacent?(coord11, :BISHOP)) # :ROOK
		adjacent_coords = coord11.get_adjacent_coords
		assert_equal(4, adjacent_coords.length)
		assert_equal(Coord.new(1,0), adjacent_coords[0]) # N of 1,1
	end

end