#!/usr/bin/env perl
use v5.42;

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util qw(sum all);

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 14);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 14: Parabolic Reflector Dish";

solve_part_one(@input);
solve_part_two(@input);

exit( 0 );

sub solve_part_one(@input) {
	my $platform = g2_make();
	$platform->load(@input);

	roll_rocks($platform, "N");
	my $total = measure_total_load($platform);

	say "Part One: the total load on the north is $total.";
}

sub solve_part_two(@input) {
	my $platform = g2_make();
	$platform->load(@input);

	my $load = spin_cycle($platform);

	say "Part Two: the load on the north after a spin cycle is $load.";
}

sub spin_cycle($platform) {
	# Go until steady state
	my @loads = ();
	my %load_indexes = ();
	my $cycle = 0;
	my $limit = 1000000000;
	my $start_of_cycle = 0;
	for my $i (1..$limit) {
		roll_rocks($platform, "N");
		roll_rocks($platform, "W");
		roll_rocks($platform, "S");
		roll_rocks($platform, "E");
		my $load = measure_total_load($platform);
		push(@loads, $load);
		$load_indexes{$load} = [] if !defined($load_indexes{$load});
		push(@{$load_indexes{$load}}, $i);
		if (scalar @{$load_indexes{$load}} > 2) {
			$cycle = find_cycle(\@loads);
		}
		say $i; # . " " . join(',', @loads);
		if ( $cycle > 0 ) {
			say "found cycle of $cycle after $i spins.";
			say join(',', @loads);
			$start_of_cycle = $i;
			last;
		}
	}

	my $remainder = ($limit - $start_of_cycle) % $cycle;
# 	say "$remainder = ($limit - $start_of_cycle) % $cycle";
	my $idx = $#loads - $cycle + $remainder;
# 	say "$idx = $#loads - $cycle + $remainder";
	return $loads[$idx];
}

sub find_cycle($loads_ref) {
	my @loads = @{$loads_ref};
	my $ptr = $#loads-1;

	while ($ptr > $#loads / 2) {
		if ($loads[$ptr] == $loads[-1]) {
			my $off = 1;
			my $i = $ptr - $off; my $j = $#loads - $off;
			while ($i >= 0 and $loads[$i] == $loads[$j]) {

				$off++;
				$i = $ptr - $off; $j = $#loads - $off;
			}
			if ($i >= 0 && $j == $ptr-1) {
				return $off-1;
			}
		}
		$ptr--;
	}

	return 0;
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
