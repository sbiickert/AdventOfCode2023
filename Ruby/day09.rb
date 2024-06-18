#!/usr/bin/env ruby

require 'util'
#require 'geometry'
#require 'grid'

# INPUT_FILE = 'day09_test.txt'
INPUT_FILE = 'day09_challenge.txt'

puts 'Advent of Code 2023, Day 09: Mirage Maintenance'

class Oasis
  def initialize(defn)
    @sequence = defn.split(/ +/).map { |num| Integer(num) }
    @pyramid = nil
  end
  
  def next_number
    build_pyramid if @pyramid == nil
    @pyramid[0][-1]
  end
  
  def prev_number
    build_pyramid if @pyramid == nil
    @pyramid[0][0]
  end
  
  def build_pyramid
    @pyramid = [@sequence.dup]

    i = 0
    while !all_zeroes(@pyramid[i])
      next_row = []
      for j in (0 ... @pyramid[i].length-1) do
        next_row << @pyramid[i][j+1] - @pyramid[i][j]
      end
      @pyramid << next_row
      i += 1
    end
    
    # Add the first and last values
    @pyramid[i].unshift(0)
    @pyramid[i].push(0)
    i -= 1
    while i >= 0
      @pyramid[i].unshift(@pyramid[i][0] - @pyramid[i+1][0])
      @pyramid[i].push(@pyramid[i][-1] + @pyramid[i+1][-1])
      i -= 1
    end
  end
  
  def all_zeroes(arr)
    for val in arr do
      return false if val != 0
    end
    true
  end
end

def solve_part_one(oases)
  numbers = oases.map { |oasis| oasis.next_number }
  sum = numbers.inject(:+)
  puts "Part One: the sum of next numbers is #{sum}"
end


def solve_part_two(oases)
  numbers = oases.map { |oasis| oasis.prev_number }
  sum = numbers.inject(:+)
  puts "Part Two: the sum of previous numbers is #{sum}"
end


input1 = Util.read_grouped_input("../Input/#{INPUT_FILE}", 0)
oases = input1.map { |line| Oasis.new(line) }
solve_part_one oases

# input2 = Util.read_grouped_input("../Input/#{INPUT_FILE}", 0)
# oases = input2.map { |line| Oasis.new(line) }
solve_part_two oases
