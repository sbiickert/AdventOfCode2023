#!/usr/bin/env ruby

require 'util'
require 'geometry'
require 'grid'

INPUT_FILE = 'day11_test.txt'
#INPUT_FILE = 'day11_challenge.txt'

input = Util.read_input("../Input/#{INPUT_FILE}")

puts 'Advent of Code 2023, Day 11: Cosmic Expansion'

def solve_part_one(input)
  puts 'hello'
end


def solve_part_two(input)

end

# Storing galaxies by row and col
rows = []
cols = []

def get_galaxies(input)
  map = Grid.new
  map.load(input)
  coords = map.coords # All coords with a galaxy
  
  rows = Array.new(Array.new)
  cols = Array.new([])
  
  coords.each do |coord|
    rows[coord.row] << coord
    cols[coord.col] << coord
  end
end

get_galaxies(input)
puts rows

solve_part_one input
#solve_part_two input
