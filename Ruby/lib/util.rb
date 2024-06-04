#!/usr/bin/env ruby

module Util

extend self

# read_input

# Reads the specified file and returns an array of strings.

# If remove_empty_lines is true, will remove any zero-length lines
# (after chomp)
def read_input(input_file, read_empty_lines=false)

	content = []

	File.open(input_file, 'r') do |file|
		file.each_line do |line|
			line.chomp!
			content << line if line.length > 0 || read_empty_lines
		end
	end
	
	content
end

# read_grouped_input

# If group_index is not given or negative, then all
# groups are returned as an array of array refs.

# If group_index is a valid index for a group, then
# only the lines of that group are returned as an array of strings.

# If group_index is out of range, then an empty array is returned.
def read_grouped_input(input_file, group_index=-1)

	content = read_input(input_file, true)
	groups = []
	g = []
	
	content.each do |line|
		if line == '' then
			groups << g
			g = []
		else
			g << line
		end
	end
	
	groups << g if g.length > 0
	
	if group_index >= 0 then
		if group_index < groups.length then
			return groups[group_index]
		end
		return []
	end
	
	groups
end
	
# approx_equal

# Avoids the issues with floating point numbers that are close
# to being equal but are not exactly equal.

# threshold is the maximum allowable difference between float1
# and float2 for them to be considered equal.
def approx_equal?(float1, float2, threshold=0.0001)
	difference = (float1 - float2).abs
	difference < threshold
end


# reduce
# Removed: ruby has a rational numeric type that automatically reduces
# e.g. 3/12r --> (1/4)


# Greatest Common Divisor

# Takes two integers and returns the GCD
def gcd(x, y)
    a = 0;
    b = [x,y].max
	r = [x,y].min
	while r != 0 
        a = b;
        b = r;
    	r = a % b;
	end
	b
end


# Least Common Multiple

# Takes an array of integers and returns the LCM
def lcm(values)
	return 0 if values.length == 0

	running = values.shift
	while values.length > 0
		next_val = values.shift
		running = running / gcd(running, next_val) * next_val
	end
	running
end


end