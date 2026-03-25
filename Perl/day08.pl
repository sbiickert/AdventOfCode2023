#!/usr/bin/env perl
use v5.40;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;

use AOC::Util;
#use AOC::Geometry;
#use AOC::Grid;

my $DAY = sprintf("%02d", 8);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_grouped_input("../input/$INPUT_FILE", 0);

say "Advent of Code 2023, Day 8: Haunted Wasteland";

my @turns;
my %network;

parse_input(@input);

solve_part_one();
#solve_part_two(@input);

exit( 0 );

sub solve_part_one() {
	my $p = 0;
	my $node = "AAA";
	my $count = 0;
	while ($node ne "ZZZ") {
		$node = ($turns[$p] eq "L") ? $network{$node}[0] : $network{$node}[1];
		$p++; $count++;
		$p = $p % (scalar @turns);
	}

	say "Part One: it took $count turns to get to ZZZ.";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub parse_input(@input) {
	@turns = split(//, shift(@input));
	%network = ();
	for my $line (@input) {
		my @info = $line =~ m/([A-Z]{3})/g;
		$network{$info[0]} = [$info[1], $info[2]];
	}
}
