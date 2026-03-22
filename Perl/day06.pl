#!/usr/bin/env perl
use v5.40;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'product';

use AOC::Util;

my $DAY = sprintf("%02d", 6);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../input/$INPUT_FILE");

say "Advent of Code 2023, Day 6: Wait For It";

my @races = parse_races(@input);

solve_part_one();
#solve_part_two(@input);

exit( 0 );

sub solve_part_one() {
	my @win_counts = ();
	for my $race (@races) {
		my $count = get_winning_move_count(%{$race});
		push(@win_counts, $count);
	}

	my $result = product(@win_counts);
	say "Part One: the product of winning move counts is $result";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub get_winning_move_count(%race) {
	my $has_won = 0;
	my $is_winning = 0;
	my $count = 0;
	my $hold = 1;
	while (1) {
		$is_winning = $hold * ($race{'time'} - $hold) > $race{'record'};
		$count++ if $is_winning;
		$has_won = $has_won || $is_winning;
		$hold++;
		last if ($has_won && !$is_winning);
	}
	return $count;
}

sub parse_races(@input) {
	my @times = $input[0] =~ m/(\d+)/g;
	my @records = $input[1] =~ m/(\d+)/g;

	my @races = ();
	for my $i (0..$#times) {
		my %race = ('time' => $times[$i], 'record' => $records[$i]);
		push(@races, \%race);
	}
	return @races;
}
