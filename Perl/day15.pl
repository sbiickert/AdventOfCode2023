#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'sum';

use AOC::Util;

my $DAY = sprintf("%02d", 15);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 15: Lens Library";

solve_part_one($input[0]);
#solve_part_two(@input);

exit( 0 );

sub solve_part_one($line) {
	my @steps = split(/,/, $line);
	my @values = map {hash_string($_)} @steps;
	my $total = sum @values;

	say "Part One: the sum of the hash results is $total.";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub hash_string($str) {
	my $value = 0;
	for my $char (split(//, $str)) {
		my $ascii = ord($char);
		$value = (($value + $ascii) * 17) % 256;
	}
	return $value;
}
