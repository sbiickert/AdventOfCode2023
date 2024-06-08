#!/usr/bin/env ruby

require 'util'
#require 'geometry'
#require 'grid'

# INPUT_FILE = 'day04_test.txt'
INPUT_FILE = 'day04_challenge.txt'

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
  
  def win_count
    w_set = Set.new(@winning_numbers)
    m_set = Set.new(@my_numbers)
    common = w_set.intersection(m_set)
    common.length
  end
  
  def points
    wc = win_count
    return 0 if wc == 0
    2**(wc-1)
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


def solve_part_two(cards)
  card_counts = Hash.new(default=0)
  cards.each do |card|
    card_counts[card.id] += 1
    wc = card.win_count
    for i in 1..wc
      card_counts[card.id + i] += card_counts[card.id]
    end
  end
  puts "The total number of cards is #{card_counts.values.inject(:+)}"
end

cards = input.map { ScratchCard.new(_1) }


solve_part_one cards
solve_part_two cards
