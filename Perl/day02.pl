#!/usr/bin/env perl
use v5.40;

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
#use Data::Printer;
use List::Util qw( max );
#use Storable 'dclone';

use AOC::Util;
#use AOC::Geometry;
#use AOC::Grid;

#my $INPUT_FILE = 'day02_test.txt';
my $INPUT_FILE = 'day02_challenge.txt';
my @input = read_input("../input/$INPUT_FILE");

say "Advent of Code 2023, Day 02: Cube Conundrum";

solve_part_one(@input);
solve_part_two(@input);

exit( 0 );

sub solve_part_one(@input) {
	my $sum_possible_ids = 0;
	for my $line (@input) {
		my $game = parse_game($line);
		if( is_game_possible($game, 12, 13, 14) ) {
			$sum_possible_ids += $game->{"id"};
		}
	}
	say "Part One: the sum of ids of possible games is: $sum_possible_ids";
}

sub solve_part_two(@input) {
	my $sum_power = 0;
	for my $line (@input) {
		my $game = parse_game($line);
		$sum_power += calc_power($game);
	}
	say "Part Two: the sum of cube power is: $sum_power";
}

sub is_game_possible($game, $r_limit, $g_limit, $b_limit) {
	my $maximums = get_maximum_observed_counts($game);
	return ($maximums->{"red"} <= $r_limit &&
			$maximums->{"green"} <= $g_limit &&
			$maximums->{"blue"} <= $b_limit);
}

sub calc_power($game) {
	my $maximums = get_maximum_observed_counts($game);
	return ($maximums->{"red"} * $maximums->{"green"} * $maximums->{"blue"});
}

sub get_maximum_observed_counts($game) {
	my @draws = @{$game->{"draws"}};
	my %maximums = ("red" => 0, "green" => 0, "blue" => 0);
	for my $draw (@draws) {
		for my $color (keys %maximums) {
			$maximums{$color} = max($maximums{$color}, $draw->{$color});
		}
	}
	return \%maximums;
}

sub parse_game($line) {
	my %game = ();
	my ($game_info, $draws_str) = split(": ", $line);
	$game_info =~ m/(\d+)/;
	$game{"id"} = $1;

	my @draws = ();
	my @each_draw_string = split("; ", $draws_str);
	for my $draw_string (@each_draw_string) {
		my %draw = ("red" => 0, "green" => 0, "blue" => 0);
		while ( $draw_string =~ m/(\d+) (red|green|blue)/g ) {
			$draw{$2} = $1;
		}
		push(@draws, \%draw);
	}
	$game{"draws"} = \@draws;
	return \%game;
}