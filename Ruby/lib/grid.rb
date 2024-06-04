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
	
	def get_s(coord)
		val = @data[coord]
		if val.kind_of?(String) then
			return val
		elsif val.kind_of?(Array) then
			return val.first
		elsif val.kind_of?(Hash) then
			return val[:glyph]
		elsif val.respond_to?(:glyph) then
			return val.glyph
		end
		return String(val)
	end
	
	def set(coord, value)
		@data[coord] = value
		
		#Update extent
		if !@extent || !extent.contains?(coord) then
			@extent = Extent.new(*@data.keys)
		end
	end
	
	def clear(coord, reset_extent=false)
		@data.delete(coord)
		@extent = Extent.new(*@data.keys) if reset_extent
	end
	
	def coords(with_value=nil)
		result = @data.keys
		
		if with_value != nil then
			result.select! { |coord| @data[coord] == with_value }
		end
		
		result
	end
	
	def histogram(include_unset=false)
		hist = Hash.new(default=0)
		coords_to_summarize = []
		if (include_unset) then
			coords_to_summarize = @extent.all_coords.to_a
		else
			coords_to_summarize = self.coords
		end
		
		coords_to_summarize.each do |c|
			val = self.get_s(c)
			hist[val] += 1
		end
		
		return hist
	end
	
	def neighbors(coord)
		coord.get_adjacent_coords(@rule)
	end
	
	def print(markers=nil, invert_y=false)
		puts self.to_s(markers, invert_y)
	end
	
	def to_s(markers=nil, invert_y=false)
		return '' if @extent == nil
		str = ''
		
		xmin = @extent.min.x
		ymin = @extent.min.y
		xmax = @extent.max.x
		ymax = @extent.max.y
		
		y_indices = (ymin .. ymax).to_a
		y_indices.reverse! if invert_y
		
		y_indices.each do |y|
			row = []
			for x in xmin .. xmax do
				c = Coord.new(x, y)
				glyph = self.get_s(c)
				if markers != nil && markers[c] != nil then
					glyph = markers[c]
				end
				row.push(glyph)
			end
			row.push("\n")
			str += row.join('')
		end
		
		str
	end
	
	def load(rows)
		for r in 0 .. rows.length-1 do
			chars = rows[r].split('')
			for c in 0 .. chars.length-1 do
				if chars[c] != @default then
					self.set(Coord.new(c, r), chars[c])
				end
			end
		end
	end
end

# Mixin
module GridGlyph
	def glyph
		return @glyph
	end
end