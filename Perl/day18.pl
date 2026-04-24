#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
#use Storable 'dclone';

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 18);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 18: Lavaduct Lagoon";

my @instructions = parse_dig(@input);
# p @instructions;

solve_part_one(@instructions);
#solve_part_two(@input);

exit( 0 );

sub solve_part_one(@instructions) {
	my $map = g2_make();
	my $loc = c2_origin;
	$map->set($loc, '#');

	for my $i (@instructions) {
		for my $dist (1..$i->{'dist'}) {
			$loc = $loc->offset($i->{'dir'});
			$map->set($loc, '#');
		}
	}

	$map->flood_fill(c2_make(1,1), '#');
	my @excavated_coords = $map->coords('#');
	my $volume = scalar @excavated_coords;

	say "Part One: the total excavated volume is $volume.";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub parse_dig(@input) {
	my @result = ();
	for my $line (@input) {
		my @parts = split(/ /, $line);
		my %instr = ('dir' => $parts[0], 'dist' => $parts[1], 'color' => $parts[2]);
		push(@result, \%instr);
	}
	return @result;
}
