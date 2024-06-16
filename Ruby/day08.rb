#!/usr/bin/env ruby

require 'util'
#require 'geometry'
#require 'grid'

# INPUT_FILE = 'day08_test.txt'
INPUT_FILE = 'day08_challenge.txt'

input = Util.read_grouped_input("../Input/#{INPUT_FILE}", 0)

puts 'Advent of Code 2023, Day 08: Haunted Wasteland'

class DesertNode
  def initialize(defn)
    m = defn.match(/([\w]{3}) = \(([\w]{3}), ([\w]{3})\)/)
    @label = m.captures[0]
    @left = m.captures[1]
    @right = m.captures[2]
  end
  
  attr_reader :label, :left, :right
  
  def get_node_label(dir)
    if dir == "L" then
      return @left
    elsif dir == "R" then
      return @right
    end
    nil
  end
  
  def to_s
    "#{@label} -> (#{@left}, #{@right})"
  end
end

def solve_part_one(dirs, network)
  steps = 0
  i = 0
  current_node = network['AAA']
  while current_node.label != 'ZZZ' do
    dir = dirs[i]
    next_label = current_node.get_node_label(dir)
    current_node = network[next_label]
    i += 1
    i = i % dirs.length
    steps += 1
  end
  puts "The total number of steps to reach ZZZ is #{steps}"
end


def solve_part_two(input)

end

def parse_input(input)
  dirs = input.shift.split('')
  network = Hash.new
  input.each do |line|
    node = DesertNode.new(line)
    network[node.label] = node
  end
  [dirs, network]
end

dirs, network = parse_input(input)

solve_part_one(dirs, network)
#solve_part_two input
