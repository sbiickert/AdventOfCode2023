#!/usr/bin/env perl
use v5.42;

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 21);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 21: Step Counter";

my $grid = g2_make('@');
$grid->load(@input);
my @s = $grid->coords("S");
$grid->set($s[0], '.');

solve_part_one($grid, $s[0]);
solve_part_two($grid, $s[0]);

exit( 0 );

sub solve_part_one($grid, $start) {
	my $iterations = ($grid->extent()->width < 20) ? 6 : 64;

	my %locations = ($start->to_str() => 1);
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

sub solve_part_two($grid, $start) {
	my %visited = ();
	my %next_steps = ();
	my $ext = $grid->extent();

	my $distance_grid = g2_make();
	$distance_grid->set($start, 0);

	my @n = grep {$grid->get_scalar($_) eq '.'} $grid->neighbors($start);
	for my $n (@n) { my $s = $n->to_str(); if (!defined $visited{$s}) {$next_steps{$s} = 1 } }

	my $distance = 1;
	while (scalar %next_steps > 0) {
		my @to_visit = map {c2_from_str($_)} keys %next_steps;
		%next_steps = ();
		for my $plot (@to_visit) {
			$distance_grid->set($plot, $distance);
			$visited{$plot->to_str()} = 1;
			@n = grep {$ext->contains($_) && $grid->get_scalar($_) eq '.'} $grid->neighbors($plot);
			for my $n (@n) {
				my $s = $n->to_str();
				if (!defined $visited{$s}) {
					$next_steps{$s} = 1
				}
			}
		}
		$distance++;
	}

	# https://github.com/villuna/aoc23/wiki/A-Geometric-solution-to-advent-of-code-2023,-day-21
	my $hist_ref = $distance_grid->histogram();
	my %hist = %{$hist_ref};
	my $even_corners = 0;	my $odd_corners = 0;
	my $even_full = 0;		my $odd_full = 0;
	for my $value (keys %hist) {
		$even_corners += $hist{$value} if $value % 2 == 0 && $value > 65;
		$odd_corners += $hist{$value} if $value % 2 == 1 && $value > 65;

		$even_full += $hist{$value} if $value % 2 == 0;
		$odd_full += $hist{$value} if $value % 2 == 1;
	}

	my $w = $ext->width();
	my $n = sprintf("%.0f", ((26501365 - $w / 2) / $w));
	die "$n" unless ($n == 202300);

	my $answer = (($n+1)*($n+1)) * $odd_full + ($n*$n) * $even_full - ($n+1) * $odd_corners + $n * $even_corners;

	say "Part Two: the number of visited plots on an infinite grid is $answer.";
}
