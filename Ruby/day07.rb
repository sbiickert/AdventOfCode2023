#!/usr/bin/env ruby

require 'util'
#require 'geometry'
#require 'grid'

# INPUT_FILE = 'day07_test.txt'
INPUT_FILE = 'day07_challenge.txt'

input = Util.read_input("../Input/#{INPUT_FILE}")

puts 'Advent of Code 2023, Day 07: Camel Cards'


class CamelHand
  @@labels = 'AKQJT98765432'.split('')
  @@types = [:five_of_a_kind, :four_of_a_kind, :full_house, :three_of_a_kind, :two_pair, :one_pair, :royal_sampler]
  @@wild = false
  
  def self.enable_wild(enabled)
    @@wild = enabled
    @@labels = @@wild ? 'AKQT98765432J'.split('') : 'AKQJT98765432'.split('')
  end

  def initialize(str)
    @source = str
  end
  
  attr_reader :source
  
  def cards
    return @source.split('')
  end
  
  def type
    calc_hand_type
  end
  
  def calc_hand_type
    freq = Hash.new(default=0)
    @source.split('').each do |card|
      freq[card] += 1
    end
    
    wild_count = 0
    if @@wild then
      wild_count = freq['J']
      freq['J'] = 0
    end
    
    if freq.has_value?(5) || wild_count == 5 then
      return :five_of_a_kind
      
    elsif freq.has_value?(4) then
      return :four_of_a_kind if wild_count == 0
      return :five_of_a_kind
      
    elsif freq.has_value?(3) then
      return :five_of_a_kind if wild_count == 2
      return :four_of_a_kind if wild_count == 1
      return :full_house if freq.has_value?(2)
      return :three_of_a_kind
      
    elsif freq.has_value?(2) then
      return :five_of_a_kind if wild_count == 3
      return :four_of_a_kind if wild_count == 2 
      return :full_house if wild_count == 1 && freq.values.count(2) > 1
      return :three_of_a_kind if wild_count == 1
      return :two_pair if freq.values.count(2) > 1
      return :one_pair
    end
    
    return :five_of_a_kind if wild_count == 4
    return :four_of_a_kind if wild_count == 3
    return :three_of_a_kind if wild_count == 2
    return :one_pair if wild_count == 1
    :royal_sampler
  end
  
  def <=>(other)
    self_type_idx = @@types.index(type)
    other_type_idx = @@types.index(other.type)
    # Are different hand types? Then win based on that.
    if self_type_idx != other_type_idx then
      return other_type_idx <=> self_type_idx
    end
    # Same hand type, which is stronger with higher-value card first
    (0 ... cards.length).each do |i|
      self_card_idx = @@labels.index(cards[i])
      other_card_idx = @@labels.index(other.cards[i])
      if self_card_idx != other_card_idx then
        return other_card_idx <=> self_card_idx
      end
    end
    0 # They were the same
  end
  
  def equal?(other)
    return @source == other.source
  end
  
  alias eql? :equal?
  
  def hash
    return @source.hash
  end
end

def calc_winnings(hands)
  sorted = hands.keys.sort
#   sorted.each do |hand|
#     puts "#{hand.source} #{hand.type}"
#   end
  winnings = 0
  
  (1 .. sorted.length).each do |rank|
    hand = sorted[rank-1]
    winnings += hands[hand] * rank
  end
  winnings
end

def solve_part_one(hands)
  CamelHand.enable_wild(false)
  winnings = calc_winnings(hands)
  puts "Part One: the total winnings are #{winnings}"
end


def solve_part_two(hands)
  CamelHand.enable_wild(true)
  winnings = calc_winnings(hands)
  puts "Part Two: the total winnings are #{winnings}"
end

def parse_all_hands(input)
  result = {}
  input.each do |line|
    hand, bid = line.split(' ')
    hand = CamelHand.new(hand)
    bid = Integer(bid)
    result[hand] = bid
  end
  result
end

hands = parse_all_hands(input)

solve_part_one hands
solve_part_two hands
