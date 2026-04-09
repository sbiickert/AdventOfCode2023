#!/usr/bin/env perl
use v5.42;

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
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
solve_part_two(@patterns);

exit( 0 );

sub solve_part_one(@patterns) {
	my @scores = ();
	for my $pattern (@patterns) {
		push(@scores, score_pattern($pattern));
	}
	my $total = sum @scores;
	say "Part One: the total scores for the patterns is $total.";
}

sub solve_part_two(@input) {
	my @scores = ();
	for my $pattern (@patterns) {
		my $score;
		my $original_score = score_pattern($pattern);
		for my $coord ($pattern->extent()->all_coords()) {
			my $value = $pattern->get($coord);
			$pattern->set($coord, ($value eq '#' ? '.' : '#'));
			$score = score_pattern($pattern, $original_score);
			$pattern->set($coord, $value);
			if ($score > 0) {
				last;
			}
		}
		push(@scores, $score);
	}
	my $total = sum @scores;
	say "Part Two: the total scores for the patterns after smudge fixed is $total.";
}

sub score_pattern($pattern, $orig = -1) {
	my $idx = find_reflection_line_h($pattern, ($orig % 100 == 0) ? $orig / 100 : -1);
	if ($idx > 0) {
		my $score = $idx * 100;
		return $score;
	}
	$idx = find_reflection_line_v($pattern, ($orig % 100 != 0) ? $orig : -1);
	return $idx;
}

sub find_reflection_line_h($pattern, $orig_index) {
	my @row_vals = ();
	my $ext = $pattern->extent();
	for my $row (0..$ext->se()->Y()) {
		my $row_chars = '';
		for my $col (0..$ext->se()->X()) {
			my $val = $pattern->get("[$col,$row]");
			$row_chars .= $val;
		}
		push(@row_vals, $row_chars);
	}
	return find_reflection_line($orig_index, @row_vals);
}

sub find_reflection_line_v($pattern, $orig_index) {
	my @col_vals = ();
	my $ext = $pattern->extent();
	for my $col (0..$ext->se()->X()) {
		my $col_chars = '';
		for my $row (0..$ext->se()->Y()) {
			my $val = $pattern->get("[$col,$row]");
			$col_chars .= $val;
		}
		push(@col_vals, $col_chars);
	}
	return find_reflection_line($orig_index, @col_vals);
}

sub find_reflection_line($orig_index, @values) {
	for my $ptr (0..$#values-1) {
		next if $ptr+1 == $orig_index;
		if ($values[$ptr] eq $values[$ptr+1]) {
			# Potential reflection line. Work forwards and backwards to be sure.
			my $b = $ptr;
			my $f = $ptr+1;
			my $good = true;
			while ($b >= 0 and $f <= $#values) {
				$good = ($good and ($values[$b] eq $values[$f]));
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
