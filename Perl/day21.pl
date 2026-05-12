#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
#use Data::Printer;
#use Storable 'dclone';

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 21);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 21: Step Counter";


solve_part_one(@input);
#solve_part_two(@input);

exit( 0 );

sub solve_part_one(@input) {
	my $grid = g2_make();
	$grid->load(@input);
	my @s = $grid->coords("S");
	$grid->set($s[0], '.');

	my $iterations = ($grid->extent()->width < 20) ? 6 : 64;

	my %locations = ($s[0]->to_str() => 1);
	for my $i (1..$iterations) {
		my %next_locations = ();

		for my $plot_str (keys %locations) {
			my $plot = c2_from_str($plot_str);
			my @n = grep {$grid->get_scalar($_) eq '.'} $grid->neighbors($plot);
			for my $n (@n) {
				$next_locations{$n->to_str()} = 'O';
			}
		}

		%locations = %next_locations;
	}

	#$grid->print(\%locations);

	say "Part One: the number of visited plots is " . scalar %locations;
}

sub solve_part_two(@input) {

	say "Part Two: ";
}
