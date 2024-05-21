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


module Geometry
	extend self
	
end
