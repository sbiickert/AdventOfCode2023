#!/usr/bin/env ruby

require 'util'
require 'geometry'
require 'grid'

# INPUT_FILE = 'day10_test.txt'
INPUT_FILE = 'day10_challenge.txt'

puts 'Advent of Code 2023, Day 10: Pipe Maze'

class PipeSection
  include GridGlyph
  
  def self.from_connections(conn_set)
    %w[J L 7 F - |].each do |glyph|
      if conn_set == PipeSection.connected_directions(glyph) 
        return PipeSection.new(glyph)
      end
    end
    nil
  end
  
  def self.connected_directions(glyph)
    result = Set.new
    if glyph =~ /[-J7]/
      result << :W
    end
    if glyph =~ /[\|JL]/
      result << :N
    end
    if glyph =~ /[-LF]/
      result << :E
    end
    if glyph =~ /[\|7F]/
      result << :S
    end
    result
  end
  
  def initialize(glyph)
    @glyph = glyph
    @start_conn = nil
  end
  
  attr_accessor :glyph  
  
  def connected_directions
    PipeSection.connected_directions(@glyph)
  end
  
  def to_s
    "#{glyph} [#{connected_directions.join(', ')}]"
  end
end

def build_maze(input)
  maze = Grid.new('.', :ROOK)
  maze.load(input)
  s = maze.coords('S')[0]
  maze.coords.each do |coord|
    maze.set(coord, PipeSection.new(maze.get_s(coord)))
  end
  
  # The S position, need to substitute based on the legal connections to it.
  connections = Set.new
  dirs = Coord.adjacency_rules_defn(:ROOK)
  (0..3).each do |idx|
    dir = dirs[idx]
    rev = dirs[(idx+2) % 4]
    off = s.offset(dir)
    conn = maze.get(off) == maze.default ? [] : maze.get(off).connected_directions
    connections << dir if conn.include?(rev)
  end
  maze.set(s, PipeSection.from_connections(connections))

  [maze, s]
end

def solve_part_one(start, maze)
  ps = maze.get(start)
  positions = []
  ps.connected_directions.each do |dir|
    pos = Position.new(start,dir)
    pos = pos.move_forward
    positions << pos
  end

  distance = 1
  while positions[0].coord != positions[1].coord
    positions.each_with_index do |pos, index|
      ps = maze.get(pos.coord)
      cd_set = ps.connected_directions
      cd_set.delete(pos.opposite_direction)
      pos = pos.turn_to(cd_set.to_a()[0]).move_forward
      positions[index] = pos
    end
    distance += 1
  end
  
  puts "The furthest point of the loop is #{positions[0].coord} at distance #{distance}."
end


def solve_part_two(input)

end

input = Util.read_grouped_input("../Input/#{INPUT_FILE}", 0)

maze, start = build_maze(input)
#maze.print

solve_part_one start, maze
#solve_part_two input
