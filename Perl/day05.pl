#!/usr/bin/env perl
use v5.40;

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'min';

use AOC::Util;

my $DAY = sprintf("%02d", 5);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_grouped_input("../input/$INPUT_FILE");

say "Advent of Code 2023, Day 5: If You Give A Seed A Fertilizer";

my @seeds = parse_seeds($input[0][0]);
my @maps = parse_maps(@input[1..$#input]);

solve_part_one();
#solve_part_two(@input);

exit( 0 );

sub solve_part_one() {
	my @locations = ();
	for my $num (@seeds) {
		for my $map (@maps) {
			for my $conv (@{$map}) {
				if ($num >= $conv->[0] && $num <= $conv->[1]) {
					$num += $conv->[2];
					last;
				}
			}
		}
		push(@locations, $num);
	}
	my $min_location = min @locations;
	say "Part One: the minimum location ID is $min_location";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub parse_seeds($line) {
	my @strs = $line =~ m/(\d+)/g;
	@strs = map {$_ + 0} @strs;
	return @strs;
}

sub parse_maps(@groups) {
	my @maps = map {parse_map($_)} @groups;
}

sub parse_map(@group) {
	my @lines = @{$group[0]};
	my @result = ();
	shift @lines; # Remove the label
	for my $line (@lines) {
		my ($dest, $start, $size) = split(/ /, $line);
		push(@result, [$start+0, $start+$size, $dest-$start]);
	}
	return \@result;
}
