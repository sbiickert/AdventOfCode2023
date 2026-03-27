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

my $DAY = sprintf("%02d", 8);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

say "Advent of Code 2023, Day 8: Haunted Wasteland";

my @turns;
my %network;

parse_input( read_grouped_input("../Input/$INPUT_FILE", 0) );

solve_part_one();

if ($INPUT eq 'test') {
	parse_input(read_grouped_input("../Input/$INPUT_FILE", 1));
}

solve_part_two();

exit( 0 );

sub solve_part_one() {
	my $count = count_to_end("AAA", "ZZZ");
	say "Part One: it took $count turns to get to ZZZ.";
}

sub solve_part_two() {
	my %circuits = ();
	for my $key (keys %network) {
		if ($key =~ m/A$/) {
			$circuits{$key} = count_to_end($key, 'Z$');
		}
	}
	my $steps = lcm(values %circuits);
	say "Part Two: all ghosts end on a Z after $steps steps.";
}

sub count_to_end($start, $end) {
	my $p = 0;
	my $node = $start;
	my $count = 0;
	while (!($node =~ m/$end/)) {
		$node = ($turns[$p] eq "L") ? $network{$node}[0] : $network{$node}[1];
		$p++; $count++;
		$p = $p % (scalar @turns);
	}
	return $count;
}

sub parse_input(@input) {
	@turns = split(//, shift(@input));
	%network = ();
	for my $line (@input) {
		my @info = $line =~ m/([\w]{3})/g;
		$network{$info[0]} = [$info[1], $info[2]];
	}
}
