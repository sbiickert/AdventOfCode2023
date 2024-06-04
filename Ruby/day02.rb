#!/usr/bin/env ruby

require_relative 'lib/util'
#require_relative 'lib/geometry'
#require_relative 'lib/grid'

# INPUT_FILE = 'day02_test.txt'
INPUT_FILE = 'day02_challenge.txt'

input = Util.read_input("../Input/#{INPUT_FILE}")

puts 'Advent of Code 2023, Day 02: Cube Conundrum'

class CubeGame
	def initialize(defn)
		id_defn, draws_defn = defn.split(': ')
		game, id = id_defn.split(' ')
		@id = Integer(id)
		draws = draws_defn.split('; ')
		@draws = []
		draws.each do |draw|
			info = Hash.new(default=0)
			cube_counts = draw.split(', ')
			cube_counts.each do |cc|
				count, color = cc.split(' ')
				info[color] = Integer(count)
			end
			@draws.push(info)
		end
	end
	
	attr_reader :id
	
	def max_count(color)
		result = 0
		@draws.each do |draw|
			result = draw[color] if draw[color] > result
		end
		result
	end
	
	def power
		max_count('blue') * max_count('green') * max_count('red')
	end
end

def solve_part_one(games)
	cube_counts = {'red' => 12, 'green' => 13, 'blue' => 14}
	id_sum = 0
	games.each do |game|
		if game.max_count('red') <= cube_counts['red'] &&
			game.max_count('green') <= cube_counts['green'] &&
			game.max_count('blue') <= cube_counts['blue'] then
			
			id_sum += game.id
		end
	end
	puts "The sum of IDs of possible games is #{id_sum}"
end


def solve_part_two(games)
	power_sum = 0
	games.each do |game|
		power_sum += game.power
	end
	puts "The sum of power of the games is #{power_sum}"
end


def parse_games(input)
	games = []
	input.each do |line|
		game = CubeGame.new(line)
		games.push(game)
	end
	games
end

games = parse_games(input)

solve_part_one games
solve_part_two games
