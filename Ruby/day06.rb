#!/usr/bin/env ruby

require 'util'
#require 'geometry'
#require 'grid'

# INPUT_FILE = 'day06_test.txt'
INPUT_FILE = 'day06_challenge.txt'

input = Util.read_input("../Input/#{INPUT_FILE}")

puts 'Advent of Code 2023, Day 06: Wait For It'

class RaceRecord
  def initialize(time, dist)
    @time = Integer(time)
    @distance = Integer(dist)
  end
  
  attr_reader :time, :distance
end

class Race
  def initialize(record)
    @record = record
    calc_min_max
  end
  
  def calc_min_max
    @min = nil
    @max = nil
    (1 ... @record.time).each do |t|
      v = t
      d = (@record.time - t) * v
      @min = t if d > @record.distance && @min == nil
      @max = t-1 if d <= @record.distance && @min != nil && @max == nil
      break if @min && @max
    end
  end
  
  def win_count
    @max - @min + 1
  end
end

def solve_part(records)
  win_counts = []
  for rec in records do
    race = Race.new(rec)
    win_counts << race.win_count
  end
  
  product = win_counts.inject(:*)
end


def parse_records_one(input)
  records = []
  times = input[0].split(/ +/)
  dists = input[1].split(/ +/)
  
  (1 ... times.length).each do |i|
    records << RaceRecord.new(times[i], dists[i])
  end
  records
end

def parse_records_two(input)
  records = []
  t_line = input[0].gsub(/ +/, '')
  d_line = input[1].gsub(/ +/, '')
  times = t_line.split(':')
  dists = d_line.split(':')
  
  (1 ... times.length).each do |i|
    records << RaceRecord.new(times[i], dists[i])
  end
  records
end

records = parse_records_one(input)
product = solve_part(records)
  
puts "Part One: the product is #{product}"

records = parse_records_two(input)
product = solve_part(records)

puts "Part Two: there are #{product} ways to win"
