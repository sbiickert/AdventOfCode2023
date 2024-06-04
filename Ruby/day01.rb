#!/usr/bin/env ruby

require_relative 'lib/util'
#require_relative 'lib/geometry'
#require_relative 'lib/grid'

# INPUT_FILE = 'day01_test.txt'
INPUT_FILE = 'day01_challenge.txt'
 
input1 = Util.read_grouped_input("../input/#{INPUT_FILE}", 0)
input2 = Util.read_grouped_input("../input/#{INPUT_FILE}", 0)

puts 'Advent of Code 2023, Day 01: Trebuchet?!'

DIGIT_LOOKUP = {'one' => '1', 'two' => '2', 'three' => '3', 'four' => '4', 'five' => '5', 
				'six' => '6', 'seven' => '7', 'eight' => '8', 'nine' => '9',
				'eno' => '1', 'owt' => '2', 'eerht' => '3', 'ruof' => '4', 'evif' => '5', 
				'xis' => '6', 'neves' => '7', 'thgie' => '8', 'enin' => '9'}

def find_values_part1(str)
	m_start = str.match(/^\D*(\d)/)
	d1 = m_start.captures[0]
	m_end = str.match(/(\d)\D*$/)
	d2 = m_end.captures[0]
	#puts "#{d1} #{d2}"
	Integer(d1 + d2)
end

def find_leading_digit(str, reverse=false)
	regex = 'one|two|three|four|five|six|seven|eight|nine|1|2|3|4|5|6|7|8|9'
	if reverse then
		regex = regex.reverse
		str = str.reverse
	end
	m = str.match(/(#{regex})/)
	d1 = m.captures[0]
	d1 = DIGIT_LOOKUP[d1] || d1
	d1
end

def find_values_part2(str)
	d1 = find_leading_digit(str)
	d2 = find_leading_digit(str, true)
	#puts "#{d1} #{d2}"
	Integer(d1 + d2)
end


def solve_part_one(input)
	sum = 0
	input.each do |line|
		sum += find_values_part1(line)
	end
	
	puts "The sum of values for part 1 is #{sum}."
end


def solve_part_two(input)
	sum = 0
	input.each do |line|
		sum += find_values_part2(line)
	end
	
	puts "The sum of values for part 2 is #{sum}."
end

solve_part_one input1
solve_part_two input2
