#!/usr/bin/env perl
use Modern::Perl 2023;
our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
#use Data::Dumper;
#use Storable 'dclone';

use AOC::Util;
#use AOC::Geometry;
#use AOC::Grid;

# my $INPUT_FILE = 'day01_test.txt';
my $INPUT_FILE = 'day01_challenge.txt';
my $INDEX = 0;

my @input;

say "Advent of Code 2023, Day 01: Trebuchet!?";

@input = read_grouped_input("../input/$INPUT_FILE", 0);
my $part1 = solve_part(@input);
say "Part One: the sum of the calibration values is: $part1";

if ($INPUT_FILE =~ m/test/) {
	@input = read_grouped_input("../input/$INPUT_FILE", 1);
}
my @fixed_input = fix_input(@input);
my $part2 = solve_part(@fixed_input);
say "Part Two: the sum of the calibration values is: $part2";

exit( 0 );

sub solve_part(@input) {
	my $sum = 0;
	for my $line (@input) {
		$line =~ m/^[^\d]*(\d)/;
		my $first_num = $1;
		$line =~ m/(\d)[^\d]*$/;
		my $last_num = $1;
		my $num_string = $first_num . $last_num;
		$sum += $num_string; # auto conversion to int
	}
	return $sum;
}

sub fix_input(@input) {
	my %lookup = ("one" => "1", "two" => "2", "three" => "3",
        "four" => "4", "five" => "5", "six" => "6",
        "seven" => "7", "eight" => "8", "nine" => "9");

    my @fixed = ();
    for my $line (@input) {
    	# Trim from the start
    	while (1) {
			if ( $line =~ m/^\d/ ) { last; }
			if ( $line =~ m/^(one|two|three|four|five|six|seven|eight|nine)/ ) {
				my $digit = $lookup{$1};
				$line =~ s/^$1/$digit/;
			}
			else {
				$line = substr($line, 1);
			}
    	}
    	# Trim from the end
    	while (1) {
			if ( $line =~ m/\d$/ ) { last; }
			if ( $line =~ m/(one|two|three|four|five|six|seven|eight|nine)$/ ) {
				my $digit = $lookup{$1};
				$line =~ s/$1$/$digit/;
			}
			else {
				$line = substr($line, 0, length($line)-1);
			}
    	}
    	push(@fixed, $line);
    }

	return @fixed;
}