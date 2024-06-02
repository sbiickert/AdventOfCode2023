#!/usr/bin/env ruby

require 'geometry'

class Grid

	def initialize(default_value='.', rule=:ROOK)
		if !Coord.adjacency_rules.include?(rule) then
			rule = :ROOK
		end
		@rule = rule
		@extent = nil
		@data = Hash.new(default=default_value)
	end
	
	attr_reader :default, :rule, :extent
	
	def default()
		@data.default
	end
	
	def get(coord)
		@data[coord]
	end
	
	#def get_scalar(coord)
		# Not sure if this has value in Ruby
	#end
	
	def set(coord, value)
		@data[coord] = value
		
		#Update extent
		if !@extent || !extent.contains?(coord) then
			@extent = Extent.new(*@data.keys)
		end
	end
	
	def clear(coord, reset_extent=false)
		@data.delete(coord)
		@extent = Extent.new(@data.keys) if reset_extent
	end
	
	
end