#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'sum';

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 13);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input_groups = read_grouped_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 13: Point of Incidence";

my @patterns = map { parse_pattern( @{$_} ) } @input_groups;

solve_part_one(@patterns);
#solve_part_two(@patterns);

exit( 0 );

sub solve_part_one(@patterns) {
	my @scores = ();
	for my $pattern (@patterns) {
# 		$pattern->print();
		push(@scores, score_pattern($pattern));
	}
	my $total = sum @scores;
	say "Part One: the total scores for the patterns is $total.";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub score_pattern($pattern) {
	my $idx = find_reflection_line_h($pattern);
	if ($idx > 0) {
		return $idx * 100;
	}
	$idx = find_reflection_line_v($pattern);
	return $idx;
}

sub find_reflection_line_h($pattern) {
	my @row_vals = ();
	for my $row (0..$pattern->extent()->se()->Y()) {
		my $row_chars = '0b';
		for my $col (0..$pattern->extent()->se()->X()) {
			my $val = $pattern->get_scalar(c2_make($col, $row));
			$row_chars .= $val eq "#" ? '1' : '0';
		}
		push(@row_vals, oct($row_chars));
	}
	return find_reflection_line(@row_vals);
}

sub find_reflection_line_v($pattern) {
	my @col_vals = ();
	for my $col (0..$pattern->extent()->se()->X()) {
		my $col_chars = '0b';
		for my $row (0..$pattern->extent()->se()->Y()) {
			my $val = $pattern->get_scalar(c2_make($col, $row));
			$col_chars .= $val eq "#" ? '1' : '0';
		}
		push(@col_vals, oct($col_chars));
	}
	return find_reflection_line(@col_vals);
}

sub find_reflection_line(@values) {
	for my $ptr (0..$#values-1) {
		if ($values[$ptr] == $values[$ptr+1]) {
			# Potential reflection line. Work forwards and backwards to be sure.
			my $b = $ptr;
			my $f = $ptr+1;
			my $good = true;
			while ($b >= 0 and $f <= $#values) {
				$good = ($good and ($values[$b] == $values[$f]));
				$b--; $f++;
			}
			return $ptr+1 if $good;
		}
	}
	return 0;
}

sub parse_pattern(@group) {
	my $pattern = g2_make();
	$pattern->load(@group);
	return $pattern;
}
