#!/usr/bin/env ruby


class Coord
	
	@@offsets = {}
	@@offset_lookup = {}
	
	def self.offset(dir)
		sym = self.offset_lookup(dir)
		if @@offsets.length == 0 then
			@@offsets = {
				N:  Coord.new( 0,-1),
				NE: Coord.new( 1,-1),
				E:  Coord.new( 1, 0),
				SE: Coord.new( 1, 1),
				S:  Coord.new( 0, 1),
				SW: Coord.new(-1, 1),
				W:  Coord.new(-1, 0),
				NW: Coord.new(-1,-1),
				UNKNOWN: Coord.origin # no offset
			}
		end
		@@offsets[sym]
	end
	
	def self.offset_lookup(dir)
		if @@offset_lookup.length == 0 then
			@@offset_lookup = {
				:N => :N, 'UP' => :N, '^' => :N, 'U' => :N, 'N' => :N,
				:S => :S, 'DOWN' => :S, 'v' => :S, 'D' => :S, 'S' => :S,
				:W => :W, 'LEFT' => :W, '<' => :W, 'L' => :W, 'W' => :W,
				:E => :E, 'RIGHT' => :E, '>' => :E, 'R' => :R, 'E' => :E,
				:NW => :NW, :NE => :NE, :SW => :SW, :SE => :SE,
				'NW' => :NW, 'NE' => :NE, 'SW' => :SW, 'SE' => :SE
			}
		end
		if @@offset_lookup[dir] then
			return @@offset_lookup[dir]
		end
		:UNKNOWN
	end
	
	@@adjacency_rules = [:ROOK, :BISHOP, :QUEEN]
	@@adjacency_rules_defns = {}
	
	def self.adjacency_rules
		@@adjacency_rules.dup
	end
	
	def self.adjacency_rules_defn(rule)
		if @@adjacency_rules_defns.length == 0 then
			@@adjacency_rules_defns = {
				:ROOK   => %i[N E S W],
				:BISHOP => %i[NE SE SW NW],
				:QUEEN  => %i[N NE E SE S SW W NW]
			}
		end
		@@adjacency_rules_defns[rule].dup
	end
	
	def self.from_s(val)
		m = val.match(/\[(-?\d+),(-?\d+)\]/)
		if m then
			return Coord.new(m[1], m[2])
		end
		nil
	end
	
	def self.origin
		return Coord.new(0,0)
	end


	attr_reader :x, :y

	def initialize(x, y)
		@x = Integer(x)
		@y = Integer(y)
	end
	
	def col = @y
	def row = @x
	
	def == (other_coord)
		self.x == other_coord.x && self.y == other_coord.y
	end
	
	# The following allows Coord instances to be used as Hash keys
	alias eql? ==
	
	def hash()
		@x.hash ^ @y.hash # XOR
	end
	
	def + (other_coord)
		Coord.new(x + other_coord.x, y + other_coord.y)
	end
	
	def - (other_coord)
		Coord.new(x - other_coord.x, y - other_coord.y)
	end
	
	def delta(other_coord)
		Coord.new(other_coord.x - x, other_coord.y - y)
	end

	def offset(dir_str)
		off = Coord.offset(dir_str)
		self + off
	end
	
	def adjacent?(other_coord, rule=:ROOK)
		if (rule == :ROOK) then
			return manhattan(other_coord) == 1
		elsif (rule == :BISHOP) then
			return (x - other_coord.x).abs == 1 && (y - other_coord.y).abs == 1			
		end
		
		#QUEEN
		manhattan(other_coord) == 1 ||
		((x - other_coord.x).abs == 1 && (y - other_coord.y).abs == 1)
	end
	
	def get_adjacent_coords(rule=:ROOK)
		adj_defn = Coord.adjacency_rules_defn(rule)
		adj_defn.map { self + Coord.offset(_1) }
	end
	
	def manhattan(other_coord)
		d = delta(other_coord)
		d.x.abs + d.y.abs
	end
	
	def distance(other_coord)
		d = delta(other_coord)
		Math.sqrt(Float(d.x**2 + d.y**2))
	end
	
	def dup()
		return Coord.new(x, y)
	end
	
	def to_s()
		"[#{x},#{y}]"
	end
end


class Position

	@@rotation_lookup = {}

	def self.rotation_lookup(rot)
		if @@rotation_lookup.length == 0 then
			@@rotation_lookup = {
				:CW => :CW, 'CW' => :CW, 'R' => :CW, 'RIGHT' => :CW,
				:CCW => :CCW, 'CCW' => :CCW, 'L' => :CCW, 'LEFT' => :CCW
			}
		end
		@@rotation_lookup[rot]
	end

	attr_reader :coord, :dir
	
	def initialize(coord=Coord.origin, dir=:N)
		@coord = coord
		@dir = Coord.offset_lookup(dir)
	end
	
	def == (other)
		coord == other.coord && dir == other.dir
	end
	
	def turn(rotation)
		rot = Position.rotation_lookup(rotation)
		step = 0
		if rot == :CW then
			step = 1
		else
			step = -1
		end
		
		ordered_dirs = Coord.adjacency_rules_defn(:ROOK) # [NESW]
		index = ordered_dirs.find_index(dir)
		index = (index + step) % 4
		return Position.new(coord.dup, ordered_dirs[index])
	end
	
	def move_forward(distance=1)
		offset = Coord.offset(dir)
		move = Coord.new(offset.x * distance, offset.y * distance)
		Position.new(coord + move, dir)
	end
	
	def dup
		Position.new(coord, dir)
	end
	
	def to_s
		"{#{coord.to_s} #{dir}}"
	end
end

class Extent

	def self.from_ints(xmin, ymin, xmax, ymax)
		Extent.new(Coord.new(xmin, ymin), Coord.new(xmax, ymax))
	end
	
	def initialize(*coords)
		# Sanity code: all coords passed are sorted regardless of order given
		x_values = coords.map {|c| c.x}.sort
		y_values = coords.map {|c| c.y}.sort
		@min = Coord.new(x_values[0], y_values[0])
		@max = Coord.new(x_values[-1], y_values[-1])
	end

	attr_reader :min, :max
	
	def nw = @min
	def se = @max
	def ne = Coord.new(@max.x, @min.y)
	def sw = Coord.new(@min.x, @max.y)
	
	def == (other)
		return nil if other == nil
		@min == other.min && @max == other.max
	end
	
	def width = @max.x - @min.x + 1
	def height = @max.y - @min.y + 1
	def area = width * height
	
	def expand(to_fit_coord)
		Extent.new(@min, @max, to_fit_coord)
	end
	
	def inset(amount)
		n = @min.y + amount
		s = @max.y - amount
		w = @min.x + amount
		e = @max.x - amount
		if n > s || w > e then
			return nil
		end
		return Extent.from_ints(w, n, e, s)
	end
	
	def contains?(coord)
		(@min.x .. @max.x).include?(coord.x) && (@min.y .. @max.y).include?(coord.y)
	end
	
	def intersect(other)
		common_min_x = [@min.x, other.min.x].max
		common_max_x = [@max.x, other.max.x].min
		if common_max_x < common_min_x then
			return nil
		end
		common_min_y = [@min.y, other.min.y].max
		common_max_y = [@max.y, other.max.y].min
		if common_max_y < common_min_y then
			return nil
		end

		return Extent.new(Coord.new(common_min_x, common_min_y), 
						  Coord.new(common_max_x, common_max_y))
	end
	
	def union(other)
		if self == other then
			return [self]
		end
		results = []
		e_int = self.intersect(other)
		if e_int == nil then
			return [self, other]
		end
		results.push(e_int)
		
		[self, other].each do |e|
			next if e == e_int
			
			if (e.nw.x < e_int.nw.x) then # xmin
				if (e.nw.y < e_int.nw.y) then # ymin
					results.push(Extent.from_ints(e.nw.x, e.nw.y, e_int.nw.x-1, e_int.nw.y-1))
				end
				if (e.se.y > e_int.se.y) then # ymax
					results.push(Extent.from_ints(e.nw.x, e_int.se.y+1, e_int.nw.x-1, e.se.y))
				end
				results.push(Extent.from_ints(e.nw.x, e_int.nw.y, e_int.nw.x-1, e_int.se.y))
			end
			if (e_int.se.x < e.se.x) then
				if (e.nw.y < e_int.nw.y) then # ymin
					results.push(Extent.from_ints(e_int.se.x+1, e.nw.y, e.se.x, e_int.nw.y-1))
				end
				if (e.se.y > e_int.se.y) then # ymax
					results.push(Extent.from_ints(e_int.se.x+1, e_int.se.y+1, e.se.x, e.se.y))
				end
				results.push(Extent.from_ints(e_int.se.x+1, e_int.nw.y, e.se.x, e_int.se.y))
			end
			if (e.nw.y < e_int.nw.y) then #ymin
				results.push(Extent.from_ints(e_int.nw.x, e.nw.y, e_int.se.x, e_int.nw.y-1))
			end
			if (e_int.se.y < e.se.y) then #ymax
				results.push(Extent.from_ints(e_int.nw.x, e_int.se.y+1, e_int.se.x, e.se.y))
			end
			
		end
		results
	end
	
	def all_coords()
		Enumerator.new do |yielder|
			for x in @min.x..@max.x do
				for y in @min.y..@max.y do
					yielder.yield(Coord.new(x,y))
				end
			end
		end
	end
	
	def to_s()
		"{min: #{@min.to_s}, max: #{@max.to_s}}"
	end
end

# module Geometry
# 	extend self
# 	
# end
