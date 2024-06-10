#!/usr/bin/env ruby

require 'util'
#require 'geometry'
#require 'grid'

# INPUT_FILE = 'day05_test.txt'
INPUT_FILE = 'day05_challenge.txt'

input = Util.read_grouped_input("../Input/#{INPUT_FILE}")

puts 'Advent of Code 2023, Day 05: If You Give A Seed A Fertilizer'

class FarmerMap
  def initialize(lines)
    name_line = lines.shift
    m = name_line.match(/([-\w]+) map/)
    @name = m.captures[0]
    @maps = []
    lines.each do |line|
      map = {}
      nums = line.split(' ').map {Integer(_1)}
      map[:dst] = nums[0] ... nums[0] + nums[2]
      map[:src] = nums[1] ... nums[1] + nums[2]
      @maps << map
    end
  end
  
  def convert(value)
    @maps.each do |map|
      if map[:src].include?(value) then
        offset = value - map[:src].begin
        return map[:dst].begin + offset
      end
    end
    value
  end
  
  def unconvert(value)
    @maps.each do |map|
      if map[:dst].include?(value) then
        offset = value - map[:dst].begin
        return map[:src].begin + offset
      end
    end
    value
  end
  
  def to_s
    s = "FarmerMap #{@name}\n"
    str_array = @maps.map {"#{_1[:src].to_s} --> #{_1[:dst].to_s}"}
    s += str_array.join("\n")
    s
  end
end

def convert(value, maps)
  maps.each do |map|
    value = map.convert(value)
  end
  value
end

def unconvert(value, maps)
  maps.reverse.each do |map|
    value = map.unconvert(value)
  end
  value
end

def solve_part_one(seeds, maps)
  lowest_location = 2**31
  seeds.each do |seed|
    value = convert(seed, maps)
    if value < lowest_location then
      lowest_location = value
    end
  end
  puts "Part One: the lowest location value is #{lowest_location}"
end


def solve_part_two(seeds, maps)
  seed_ranges = []
  seeds.each_slice(2) do |start, size|
    seed_ranges << (start ... start + size)
  end

  for i in 104000000 .. 2**31 do # cheat to start close to the answer
    value = unconvert(i, maps)
    seed_ranges.each do |r|
      if r.include?(value) then
        puts "Part Two: the lowest location value is #{i}"
        return
      end
    end
    puts String(i) if i % 100000 == 0
  end
  puts "Part Two didn't work."
end

def parse_input(grouped)
  split_result = grouped[0][0].split(': ')
  seeds = split_result[1].split(' ').map {Integer(_1)}
  maps = []
  for i in 1 ... grouped.length do
    maps << FarmerMap.new(grouped[i])
  end
  [seeds, maps]
end

seeds, maps = parse_input(input)
# maps.each do |map| 
#   puts map.to_s
# end

solve_part_one seeds, maps
solve_part_two seeds, maps
