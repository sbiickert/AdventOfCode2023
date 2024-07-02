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
  
  def exit_direction(entry_dir)
    cd_set = connected_directions
    cd_set.delete(Position.opposite_direction(entry_dir))
    cd_set.to_a().first
  end
  
  def _directions(entry_dir, is_left)
    result = Set.new
    back = Position.opposite_direction(entry_dir)
    exit_dir = exit_direction(entry_dir)
    all_dirs = Coord.adjacency_rules_defn(:QUEEN)
    all_dirs = all_dirs.reverse() if is_left == false
    back_idx = all_dirs.find_index(back)
    (1..7).each do |offset| # Can't be back
      idx = (back_idx + offset) % 8
      dir = all_dirs[idx]
      return result if dir == exit_dir
      result.add(dir)
    end
    result
  end
  
  def left_directions(entry_dir)
    _directions(entry_dir, true)
  end
  
  def right_directions(entry_dir)
    _directions(entry_dir, false)
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
  clean_maze = Grid.new # Will only contain loop pipes
  
  ps = maze.get(start)
  clean_maze.set(start, ps)
  
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
      clean_maze.set(pos.coord, ps)
      new_dir = ps.exit_direction(pos.dir)
      pos = pos.turn_to(new_dir).move_forward
      positions[index] = pos
    end
    distance += 1
  end
  clean_maze.set(positions[0].coord, maze.get(positions[0].coord))
  
  puts "The furthest point of the loop is #{positions[0].coord} at distance #{distance}."
  clean_maze
end

def solve_part_two(start, maze)
  ps = maze.get(start)
  dir1, dir2 = ps.connected_directions().to_a # arbitrary
  exit_dir = dir1
  entry_dir = Position.opposite_direction(dir2)
  
  pos = Position.new(start, entry_dir)
  inside_dir = nil # Don't know. Will be > or <
  
  until inside_dir != nil && pos.coord == start do   
    lefts = ps.left_directions(pos.dir)
    lefts.each do |offset_dir|
      coord = pos.coord.offset(offset_dir)
      spilled = maze.flood_fill(coord, '<')
      if spilled && inside_dir == nil then
        inside_dir = '>'
      end
    end
    
    rights = ps.right_directions(pos.dir)
    rights.each do |offset_dir|
      coord = pos.coord.offset(offset_dir)
      spilled = maze.flood_fill(coord, '>')
      if spilled && inside_dir == nil then
        inside_dir = '<'
      end
    end
    
    pos = pos.turn_to(exit_dir)
    pos = pos.move_forward
    
    ps = maze.get(pos.coord)
    exit_dir = ps.exit_direction(pos.dir)
    entry_dir = pos.dir
  end
  
  hist = maze.histogram
  count = hist[inside_dir]
  puts "The total area inside the loop is #{count}."
end

input = Util.read_grouped_input("../Input/#{INPUT_FILE}", 0)

maze, start = build_maze(input)

clean_maze = solve_part_one start, maze
solve_part_two start, clean_maze
