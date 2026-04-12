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
	my $platform = g2a_make( length($input[0]) - 1, $#input);
	$platform->load(@input);

	roll_rocks($platform, "N");
	my $total = measure_total_load($platform);
# 	$platform->print();

	say "Part One: the total load on the north is $total.";
}

sub solve_part_two(@input) {
	my $platform = g2a_make(length($input[0]) - 1, $#input);
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
# 		$platform->print();
# 		say "";
		my $load = measure_total_load($platform);
		push(@loads, $load);
		$load_indexes{$load} = [] if !defined($load_indexes{$load});
		push(@{$load_indexes{$load}}, $i);
		my $start_after = $platform->y_max() < 20 ? 4 : 2;
		if (scalar @{$load_indexes{$load}} > $start_after) {
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

	my ($xs, $ys) = $platform->xy("O");
	my $height = $platform->y_max() + 1;

	for my $i (0..$#{$xs}) {
		my $load = $height - $ys->[$i];
		push(@loads, $load);
	}

	return sum @loads;
}

sub roll_rocks($platform, $dir) {
	my $x_max = $platform->x_max();
	my $y_max = $platform->y_max();
	my @off = xy_offset($dir);

	my $move_count = 1;
	while ($move_count > 0) {
		$move_count = 0;
		my ($xs, $ys) = $platform->xy("O");
		for my $i (0..$#{$xs}) {
			my $x = $xs->[$i];
			my $y = $ys->[$i];
			my @xy_n = ($x + $off[0], $y + $off[1]);
			while ($xy_n[0] >= 0 && $xy_n[0] <= $x_max &&
					$xy_n[1] >= 0 && $xy_n[1] <= $x_max and
					$platform->get_xy(@xy_n) eq ".") {
				$platform->set_xy($x, $y, ".");
				$platform->set_xy(@xy_n, "O");
				$x = $xy_n[0];
				$y = $xy_n[1];
				@xy_n = ($x + $off[0], $y + $off[1]);
				$move_count++;
			}
		}
	}
}
