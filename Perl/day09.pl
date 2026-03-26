#!/usr/bin/env perl
use v5.40;

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util qw( all sum );

use AOC::Util;

my $DAY = sprintf("%02d", 9);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_grouped_input("../input/$INPUT_FILE", 0);

say "Advent of Code 2023, Day 9: Mirage Maintenance";

my @histories = map { build_history($_) } @input;

solve_part('One');
solve_part('Two');

exit( 0 );

sub solve_part($part) {
	my @extrapolated = ();
	for my $h (@histories) {
		my @h = @{$h};
		my $ext_num = 0;
		for (my $i = $#h-1; $i >= 0; $i--) {
			if ($part eq 'One') {
				$ext_num = $h[$i][-1] + $ext_num;
			}
			else {
				$ext_num = $h[$i][0] - $ext_num;
			}
		}
		push(@extrapolated, $ext_num);
	}
	my $total = sum(@extrapolated);
	say "Part $part: the total of the extrapolated values is $total.";
}

sub build_history($line) {
	my @h = ();
	my @first_row = split(/ +/, $line);
	push(@h, \@first_row);
	my @diffs;
	do {
		my @last_row = @{$h[$#h]};
		my @d = mk_diffs(@last_row);
		push(@h, \@d);
		@diffs = @d;
	} until (all { $_ == 0 } @diffs);
	return \@h;
}

sub mk_diffs(@nums) {
	my @d = ();
	for my $i (1..$#nums) {
		push( @d, $nums[$i] - $nums[$i-1]);
	}
	return @d;
}
