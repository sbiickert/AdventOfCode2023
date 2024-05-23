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

	def test_position
		p1 = Position.new(Coord.origin)
		assert_equal(Coord.new(0,0), p1.coord)
		assert_equal(:N, p1.dir)
		
		p2 = Position.new(Coord.new(5,5), '<')
		assert_equal(:W, p2.dir)
		p2 = p2.turn(:CW)
		assert_equal(:N, p2.dir)
		p2 = p2.turn(:CCW)
		assert_equal(:W, p2.dir)
		6.times do
			p2 = p2.turn('CCW')
		end
		assert_equal(:E, p2.dir)
		
		p3 = p2.move_forward
		assert_equal(Coord.new(6,5), p3.coord)
		p4 = p3.move_forward(4)
		assert_equal(Coord.new(10,5), p4.coord)
		
		p5 = Position.new(Coord.origin, ':-)') # UNKNOWN direction
		assert_equal(:UNKNOWN, p5.dir)
		p6 = p5.move_forward
		assert_equal(p5, p6)
	end
end