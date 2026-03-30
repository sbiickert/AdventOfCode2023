#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use Math::Combinatorics 'combine';
use List::Util 'sum';

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 11);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 11: Cosmic Expansion";

my $grid = g2_make();
$grid->load(@input);

my $p1 = solve_part(2);
say "Part One: the sum of distances is $p1.";

my $p2 = solve_part(1000000);
say "Part Two: the sum of distances is $p2.";

exit( 0 );

sub solve_part($factor) {
	my $galaxy = expand_galaxy($grid, $factor);

	my @coords = $galaxy->coords();
	my @all_pairs = combine( 2, (0..$#coords));

	my @distances = ();
	for my $pair (@all_pairs) {
		my ($i,$j) = @{$pair};
		push(@distances, $coords[$i]->manhattan($coords[$j]));
	}

	my $total = sum @distances;
	return $total;
}

sub expand_galaxy($grid, $factor) {
	my ($empty_rows_ref, $empty_cols_ref) = get_empty_rows_and_cols();

	my $expanded = g2_make();
	for my $coord ($grid->coords()) {
		my @lt = get_values_less_than($coord->X(), @{$empty_cols_ref});
		my $empty_col_count = scalar @lt;
		my $x = $coord->X() + ($empty_col_count * ($factor-1));
		@lt = get_values_less_than($coord->Y(), @{$empty_rows_ref});
		my $empty_row_count = scalar @lt;
		my $y = $coord->Y() + ($empty_row_count * ($factor-1));

		$expanded->set(c2_make($x, $y), '#');
	}
	return $expanded;
}

sub get_values_less_than($value, @arr) {
	# Assumes @arr is sorted
	for my $p (0..$#arr) {
		return @arr[0..$p-1] if $arr[$p] > $value;
	}
	return @arr;
}

sub get_empty_rows_and_cols() {
	my %rows = ();
	my %cols = ();
	for my $coord ($grid->coords()) {
		$rows{$coord->Y()} = 1;
		$cols{$coord->X()} = 1;
	}

	my @empty_rows = ();
	for my $y ($grid->extent()->nw()->Y()..$grid->extent()->se()->Y()) {
		push(@empty_rows, $y) if !exists $rows{$y};
	}
	my @empty_cols = ();
	for my $x ($grid->extent()->nw()->X()..$grid->extent()->se()->X()) {
		push(@empty_cols, $x) if !exists $cols{$x};
	}

	return \@empty_rows, \@empty_cols;
}
