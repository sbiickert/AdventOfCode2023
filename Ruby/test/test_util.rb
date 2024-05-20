#!/usr/bin/env ruby

require 'minitest/autorun'
require 'util'

INPUT_PATH = '../Input';
INPUT_FILE = 'day00_test.txt';

class TestUtil < Minitest::Test

	#include Util
	
	def test_read_input
		# 'Testing reading input'
		input = Util.read_input("#{INPUT_PATH}/#{INPUT_FILE}", true)
		assert_equal(10, input.length, "Lines in file");
		assert_equal("G1, L0", input[4]);

		# 'Testing reading input, ignoring empty lines'
		input = Util.read_input("#{INPUT_PATH}/#{INPUT_FILE}", false)
		assert_equal(8, input.length);
		assert_equal("G1, L1", input[4]);
	end

	def test_read_grouped_input
		# 'Testing reading grouped input'
		input_groups = Util.read_grouped_input("#{INPUT_PATH}/#{INPUT_FILE}")
		assert_equal(3, input_groups.length)
		assert_equal('G1, L0', input_groups[1][0])
		
		# 'Testing just reading group 1'
		group = Util.read_grouped_input("#{INPUT_PATH}/#{INPUT_FILE}", 1)
		assert_equal(2, group.length)
		
		# 'Testing just reading a group index out of range (10)'
		group = Util.read_grouped_input("#{INPUT_PATH}/#{INPUT_FILE}", 10)
		assert_equal(0, group.length)
	end

	
	def test_approx_equal
		# 'Testing approximate equality';
		f1 = 10.0;
		f2 = 11.0 - 1.0;
	
		assert(Util.approx_equal?(f1, f2))
		assert(Util.approx_equal?(f1, f2, 0.0000001))
	
		f3 = 10.01;
		refute(Util.approx_equal?(f1, f3));
	end
	
	def test_reduce()
		fractions = [[2, 4], [2, 6], [2, 8], [3,13], [3,12,99], [1]]
		reduced = [];
		fractions.each { |frac|
			r = Util.reduce(frac)
			reduced << r
		}
	
		p reduced
		
		assert(reduced[0][0] == 1 && reduced[0][1] == 2, "Reduction of 2/4.");
		assert(reduced[1][0] == 1 && reduced[1][1] == 3, "Reduction of 2/6.");
		assert(reduced[2][0] == 1 && reduced[2][1] == 4, "Reduction of 2/8.");
		assert(reduced[3][0] == 3 && reduced[3][1] == 13, "Reduction of 3/13.");
		assert(reduced[4][0] == 1 && reduced[4][1] == 4, "Reduction of 3/12.");
		assert_nil(reduced[5], "Illegal fraction.");
	end
	
	def test_gcd()
		assert_equal(2, Util.gcd(2,4), 'GCD of 2 and 4')
		assert_equal(5, Util.gcd(15,20), 'GCD of 15 and 20')
		assert_equal(1, Util.gcd(13,20), 'GCD of 13 and 20')
	end
	
	def test_lcm()
		assert_equal(12, Util.lcm([2,3,4]), 'LCM of 2, 3, 4')
		assert_equal(156, Util.lcm([3,4,13]), 'LCM of 3, 4, 13')
	end
end