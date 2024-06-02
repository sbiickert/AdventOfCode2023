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
	
	def test_extent
		e0 = Extent.new(Coord.new(-1,1), Coord.new(2,8))
		assert_equal('{min: [-1,1], max: [2,8]}', e0.to_s)
		assert_equal(-1, e0.min.x)
		assert_equal(2, e0.max.x)
		assert_equal(1, e0.min.y)
		assert_equal(8, e0.max.y)
		assert_equal(Coord.new(2,1), e0.ne)
		assert_equal(Coord.new(-1,8), e0.sw)
		e1 = Extent.from_ints(-1,1,2,8)
		assert_equal(e0, e1)
		e2 = e0.expand(Coord.new(3,3))
		assert_equal(Extent.from_ints(-1,1,3,8), e2)
		assert_equal(5, e2.width)
		assert_equal(8, e2.height)
		assert_equal(40, e2.area)
		e3 = e0.inset(1)
		assert_equal(Extent.from_ints(0,2,1,7), e3)
		e4 = e0.inset(2)
		assert_nil(e4)
		
		all = e0.all_coords.to_a
		assert_equal(e0.area, all.length)
		e_big = Extent.from_ints(0,0,100000000000,100000000000)
		assert_equal(Coord.origin, e_big.all_coords.first) # lazy enumerator :-)
		
		e_intersection = Extent.from_ints(1,1,10,10).intersect(Extent.from_ints(5,5,12,12))
		assert_equal(Extent.from_ints(5,5,10,10), e_intersection)
		e_intersection = Extent.from_ints(1,1,10,10).intersect(Extent.from_ints(5,5,7,7))
		assert_equal(Extent.from_ints(5,5,7,7), e_intersection)
		e_intersection = Extent.from_ints(1,1,10,10).intersect(Extent.from_ints(1,1,12,2))
		assert_equal(Extent.from_ints(1,1,10,2), e_intersection)
		e_intersection = Extent.from_ints(1,1,10,10).intersect(Extent.from_ints(11,11,12,12))
		assert_nil(e_intersection)
		e_intersection = Extent.from_ints(1,1,10,10).intersect(Extent.from_ints(1,10,10,20))
		assert_equal(Extent.from_ints(1,10,10,10), e_intersection)
		
		products = Extent.from_ints(1,1,10,10).union(Extent.from_ints(5,5,12,12))
		expected = [Extent.from_ints(5,5,10,10),Extent.from_ints(1,1,4,4),Extent.from_ints(1,5,4,10),Extent.from_ints(5,1,10,4),Extent.from_ints(11,11,12,12),Extent.from_ints(11,5,12,10),Extent.from_ints(5,11,10,12)]
		assert_equal(expected, products)
		products = Extent.from_ints(1,1,10,10).union(Extent.from_ints(5,5,7,7))
		expected = [Extent.from_ints(5,5,7,7),Extent.from_ints(1,1,4,4),Extent.from_ints(1,8,4,10),Extent.from_ints(1,5,4,7),Extent.from_ints(8,1,10,4),Extent.from_ints(8,8,10,10),Extent.from_ints(8,5,10,7),Extent.from_ints(5,1,7,4),Extent.from_ints(5,8,7,10)]
		assert_equal(expected, products)
		products = Extent.from_ints(1,1,10,10).union(Extent.from_ints(1,1,12,2))
		expected = [Extent.from_ints(1,1,10,2),Extent.from_ints(1,3,10,10),Extent.from_ints(11,1,12,2)]
		assert_equal(expected, products)
		products = Extent.from_ints(1,1,10,10).union(Extent.from_ints(11,11,12,12))
		expected = [Extent.from_ints(1,1,10,10),Extent.from_ints(11,11,12,12)]
		assert_equal(expected, products)
		products = Extent.from_ints(1,1,10,10).union(Extent.from_ints(1,10,10,20))
		expected = [Extent.from_ints(1,10,10,10),Extent.from_ints(1,1,10,9),Extent.from_ints(1,11,10,20)]
		assert_equal(expected, products)
	end
end