#!/usr/bin/env ruby

require 'util'
#require 'geometry'
#require 'grid'

# INPUT_FILE = 'day08_test.txt'
INPUT_FILE = 'day08_challenge.txt'

input_part_1 = Util.read_grouped_input("../Input/#{INPUT_FILE}", 0)
input_part_2 = Util.read_grouped_input("../Input/#{INPUT_FILE}", 0)

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

def steps_to_goal(start_node_label, goal, dirs, network)
  steps = 0
  i = 0
  current_node = network[start_node_label]
  while !current_node.label.match(goal) do
    dir = dirs[i]
    next_label = current_node.get_node_label(dir)
    current_node = network[next_label]
    i += 1
    i = i % dirs.length
    steps += 1
  end
  steps
end

def solve_part_one(dirs, network)
  steps = steps_to_goal('AAA', /ZZZ/, dirs, network)
  puts "The total number of steps to reach ZZZ is #{steps}"
end


def solve_part_two(dirs, network)
  start_nodes = network.keys.filter { |key| key.end_with?('A') }
  cycles = start_nodes.map { |start| steps_to_goal(start, /Z$/, dirs, network) }
  total_steps = Util.lcm(cycles)
  puts "The total number of steps to simultaneously reach nodes ending in Z is #{total_steps}"
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

dirs, network = parse_input(input_part_1)
solve_part_one(dirs, network)

dirs, network = parse_input(input_part_2)
solve_part_two(dirs, network)
