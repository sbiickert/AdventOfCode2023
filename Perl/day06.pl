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

my %single_race = combine_races(@races);
solve_part_two(%single_race);

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

sub solve_part_two(%race) {
	my @win_counts = ();
	my $count = get_winning_move_count(%race);

	say "Part Two: the number of ways to win the combined race is $count";
}

sub get_winning_move_count(%race) {
	my $first_win = -1;
	my $hold = 1;
	while ($hold * ($race{'time'} - $hold) <= $race{'record'}) { $hold++; }
	$first_win = $hold;

	my $last_win = -1;
	$hold = $race{'time'};
	while ($hold * ($race{'time'} - $hold) <= $race{'record'}) { $hold--; }
	$last_win = $hold;

	return $last_win - $first_win + 1;
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

sub combine_races(@races) {
	my $time = '';
	my $record = '';
	for my $race (@races) {
		$time .= $race->{'time'};
		$record .= $race->{'record'};
	}
	return ('time' => $time + 0, 'record' => $record + 0);
}
