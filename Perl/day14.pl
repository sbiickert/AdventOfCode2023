#!/usr/bin/env perl
use v5.42;

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'sum';

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 14);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 14: Parabolic Reflector Dish";

solve_part_one(@input);
#solve_part_two(@input);

exit( 0 );

sub solve_part_one(@input) {
	my $platform = g2_make();
	$platform->load(@input);
# 	$platform->print();

	roll_rocks($platform, "N");
	my $total = measure_total_load($platform);

# 	$platform->print();

	say "Part One: the total load on the north is $total.";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub measure_total_load($platform) {
	my @loads = ();
	my $ext = $platform->extent();
	my $h = $ext->height();

	for my $coord ($platform->coords("O")) {
		my $load = $h - $coord->row();
		push(@loads, $load);
	}

	return sum @loads;
}

sub roll_rocks($platform, $dir) {
	my $ext = $platform->extent();
	my $move_count = 1;
	while ($move_count > 0) {
		$move_count = 0;
		for my $coord ($platform->coords("O")) {
			my $n = $coord->offset($dir);
			while ($ext->contains($n) and $platform->get($n) eq ".") {
				$platform->set($coord, ".");
				$platform->set($n, "O");
				$coord = $n;
				$n = $coord->offset($dir);
				$move_count++;
			}
		}
	}
}
