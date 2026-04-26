#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util qw( sum max min);

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 18);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 18: Lavaduct Lagoon";

my @instructions = parse_dig(@input);
my @pt2_instructions = fix_instructions(@instructions);
# p @pt2_instructions;

solve_part_one(@instructions);
solve_part_two(@pt2_instructions);

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

sub solve_part_two(@instructions) {
	my @coords = get_trench_coords(@instructions);
	my $cartesian_area = calc_cartesian_area(@coords);
	my $edge_area = calc_edge_area(@instructions);

	my $total = $cartesian_area + $edge_area;

	say "Part Two: the total excavated volume is $total.";
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

sub fix_instructions(@pt1) {
	my @pt2 = ();

	for my $i1 (@pt1) {
		my %instr = ();
		$i1->{'color'} =~ m/\(#(\w{5})(\d)\)/;
		my $dist = hex($1);
		$instr{'dist'} = $dist;
		my $dir = $2;
		$instr{'dir'} = 'R' if $dir == 0;
		$instr{'dir'} = 'D' if $dir == 1;
		$instr{'dir'} = 'L' if $dir == 2;
		$instr{'dir'} = 'U' if $dir == 3;
		push(@pt2, \%instr);
	}

	return @pt2;
}

sub get_trench_coords(@instructions) {
	my @coords = c2_origin;
	for my $i (@instructions) {
		my $pos = p2_make($coords[-1], $i->{'dir'});
		$pos = $pos->move_forward($i->{'dist'});
		push(@coords, $pos->coord);
	}
	return @coords;
}

sub calc_cartesian_area(@coords) {
	# This calculates the Cartesian area, which calculates for centroids
	# and so underestimates the edges
	my @xy_products = ($coords[-1]->X() * $coords[0]->Y());
	my @yx_products = ($coords[-1]->Y() * $coords[0]->Y());

	for my $i (1..$#coords) {
		push(@xy_products, $coords[$i-1]->X() * $coords[$i]->Y());
		push(@yx_products, $coords[$i-1]->Y() * $coords[$i]->X());
	}

	my $xy_sum = sum @xy_products;
	my $yx_sum = sum @yx_products;

	my $diff = $yx_sum - $xy_sum;
	if ($diff > 0) {
		return $diff / 2;
	}
	return calc_cartesian_area(reverse @coords);
}

sub calc_edge_area(@instructions) {
	#  Each edge = + 0.5
	#  Each outside corner = + 0.75
	#  Each inside corner = + 0.25
		#  Test example is 42 cartesian
		#  24 edges * 0.5 = 12
		#  9 convex turns * 0.75 = 6.75
		#  5 concave turns * 0.25 1.25
		#  Total = 62
	my $count = 0;
	my $count_l = 0; my $count_r = 0;
	my $first_pos = p2_make( c2_origin, $instructions[0]->{'dir'} );
	my $prev_pos = $first_pos;
	for my $i (@instructions) {
		my $pos = p2_make($prev_pos->coord(), $i->{'dir'});

		my $turn = which_way_to_turn($prev_pos->dir(), $pos->dir());
		if    ($turn eq 'L') { $count_l++; }
		elsif ($turn eq 'R') { $count_r++; }

		$pos = $pos->move_forward($i->{'dist'});
		$count += $i->{'dist'};
		$prev_pos = $pos;
	}

	# Close the polygon
	my $turn = which_way_to_turn($prev_pos->dir(), $first_pos->dir());
	if    ($turn eq 'L') { $count_l++; }
	elsif ($turn eq 'R') { $count_r++; }

	my $convex = max($count_l, $count_r) * 0.75;
	my $concave = min($count_l, $count_r) * 0.25;
	my $edges = ($count - ($count_l + $count_r)) * 0.5;
	my $area = $edges + $convex + $concave;

	return $area;
}

sub which_way_to_turn($from_dir, $to_dir) {
	return 'F' if $from_dir eq $to_dir;
	my @ordered = ('N', 'E', 'S', 'W');
	my $from_index = List::Util::first { $ordered[$_] eq $from_dir } 0..$#ordered;
	my $to_index = List::Util::first { $ordered[$_] eq $to_dir } 0..$#ordered;

	my $diff = $to_index - $from_index;
	if (abs($diff) > 2) { $diff *= -1 }

	return 'B' if $diff % 2 == 0;
	return 'L' if $diff < 0;
	return 'R' if $diff > 0;
}
