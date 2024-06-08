#!/usr/bin/env ruby

require 'util'
#require 'geometry'
#require 'grid'

INPUT_FILE = 'day04_test.txt'
# INPUT_FILE = 'day04_challenge.txt'

input = Util.read_input("../Input/#{INPUT_FILE}")

puts 'Advent of Code 2023, Day 04: Scratchcards'

class ScratchCard
  def initialize(defn)
    parts = defn.split(/[:|]/)
    m = parts[0].match(/(\d+)/)
    @id = Integer(m.captures[0])
    @winning_numbers = parts[1].strip.split(/ +/).map {Integer(_1)}
    @my_numbers = parts[2].strip.split(/ +/).map {Integer(_1)}
  end
  
  attr_reader :id
  
  def points
    w_set = Set.new(@winning_numbers)
    m_set = Set.new(@my_numbers)
    common = w_set.intersection(m_set)
    return 0 if common.length == 0
    2**(common.length-1)
  end
end

def solve_part_one(cards)
  sum = 0
  cards.each do |card|
    # puts "Card #{card.id} is worth #{card.points} points."
    sum += card.points
  end
  puts "The total points of the cards is #{sum}"
end


def solve_part_two(input)
  card_counts = Hash.new(default=0)
  
end

cards = input.map { ScratchCard.new(_1) }


solve_part_one cards
solve_part_two cards
