#!/usr/bin/env ruby

require 'util'
require 'geometry'
require 'grid'

# INPUT_FILE = 'day03_test.txt'
INPUT_FILE = 'day03_challenge.txt'

input = Util.read_input("../Input/#{INPUT_FILE}")

puts 'Advent of Code 2023, Day 03: Gear Ratios'

def solve_part_one(grid, lookup)
  valid_part_nums = []
  
  grid.coords.each do |coord|
    val = grid.get_s(coord)
    next if val =~ /\d/
    sym_ext = Extent.new(coord).inset(-1)
    # puts "Extent for symbol #{val} is #{sym_ext.to_s}"
    lookup.keys.each do |pn_ext|
      pn = lookup[pn_ext]
      if sym_ext.intersect(pn_ext) then
        valid_part_nums.push(pn)
      end
    end
  end
  
  sum = valid_part_nums.inject(:+)
  puts "The sum of all valid part numbers is #{sum}"
end


def solve_part_two(grid, lookup)
  gear_ratios = []
  
  grid.coords.each do |coord|
    val = grid.get_s(coord)
    next if val != '*'
    gear_ext = Extent.new(coord).inset(-1)
    part_nums = []
    lookup.keys.each do |ext|
      part_num = lookup[ext]
      if gear_ext.intersect(ext) then
        part_nums.push(part_num)
      end
    end
    if part_nums.length == 2 then
      ratio = part_nums[0] * part_nums[1]
      gear_ratios.push(ratio)
    end
  end
  
  sum = gear_ratios.inject(:+)
  puts "The sum of all gear ratios is #{sum}"
end

def find_part_numbers(grid)
  result = {}
  
  part_num = ''
  start_coord = end_coord = nil
  
  # Coords are returned in "reading order". Good for parsing the part numbers.
  grid.extent.all_coords.each do |coord|
    val = grid.get_s(coord)
    is_num = val =~ /\d/
    if is_num then
      part_num += val
      if start_coord == nil then
        start_coord = coord
      end
      end_coord = coord
    else
      if start_coord != nil then
        ext = Extent.new(start_coord, end_coord)
        # Using the extent as the key because part numbers are duplicated
        result[ext] = Integer(part_num)
        start_coord = end_coord = nil
        part_num = ''
      end
    end
  end  
  result
end

blueprint = Grid.new('.', :QUEEN)
blueprint.load(input)
part_number_extents = find_part_numbers(blueprint)
# part_number_extents.keys.each do |key|
#   puts "#{part_number_extents[key]} => #{key.to_s}"
# end

solve_part_one blueprint, part_number_extents 
solve_part_two blueprint, part_number_extents 
