#!/usr/bin/env perl
use v5.40;

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'min';

use AOC::Util;

my $DAY = sprintf("%02d", 5);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_grouped_input("../input/$INPUT_FILE");

say "Advent of Code 2023, Day 5: If You Give A Seed A Fertilizer";

# https://www.youtube.com/watch?v=EGQgUYx-2gE

my @seeds = parse_seeds($input[0][0]);
my @maps = map {parse_map($_)} @input[1..$#input];

solve_part_one();

my @seed_intervals = parse_seed_intervals($input[0][0]);

solve_part_two(@seed_intervals);

exit( 0 );

sub solve_part_one() {
	my @locations = ();
	for my $num (@seeds) {
		for my $map (@maps) {
			for my $conv (@{$map}) {
				if ($num >= $conv->[0] && $num <= $conv->[1]) {
					$num += $conv->[2];
					last;
				}
			}
		}
		push(@locations, $num);
	}
	my $min_location = min @locations;
	say "Part One: the minimum location ID is $min_location";
}

sub solve_part_two(@intervals) {
	my @locations = ();

	while (scalar(@intervals) > 0) {
		my ($x1, $x2, $map_index) = @{pop(@intervals)};

		if ($map_index >= 7) {
			push(@locations, $x1);
			next;
		}

		my @map = @{$maps[$map_index]};
		my $was_converted = 0;

		for my $conversion (@map) {
			my ($start, $end, $diff) = @{$conversion};
			if ($x1 >= $end or $x2 <= $start) {
				# No overlap of the interval with the map range
				next;
			}
			if ($x1 < $start) {
				push(@intervals, [$x1, $start, $map_index]);
				$x1 = $start;
			}
			if ($x2 > $end) {
				push(@intervals, [$end, $x2, $map_index]);
				$x2 = $end;
			}
			# Perfect overlap
			push(@intervals, [$x1+$diff, $x2+$diff, $map_index+1]);

			$was_converted = 1;
			last;
		}

		if (!$was_converted) {
			push(@intervals, [$x1, $x2, $map_index+1]);
		}
	}

	my $min_location = min @locations;
	say "Part Two: the minimum location ID is $min_location";
}

sub parse_seeds($line) {
	my @seeds = $line =~ m/(\d+)/g;
	@seeds = map {$_ + 0} @seeds;
	return @seeds;
}

sub parse_seed_intervals($line) {
	my @nums = $line =~ m/(\d+)/g;
	@nums = map {$_ + 0} @nums;
	my @intervals = ();
	for (my $i = 0; $i <= $#nums; $i += 2) {
		push(@intervals, [$nums[$i], $nums[$i]+$nums[$i+1]-1, 0]);
	}
	return @intervals;
}

sub parse_map(@group) {
	my @lines = @{$group[0]};
	my @result = ();
	shift @lines; # Remove the label
	for my $line (@lines) {
		my ($dest, $start, $size) = split(/ /, $line);
		push(@result, [$start+0, $start+$size, $dest-$start]);
	}
	return \@result;
}
