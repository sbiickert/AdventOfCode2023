#!/usr/bin/env perl
use v5.40;
use feature 'class';
no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use Set::Scalar;
use List::Util 'sum';

use AOC::Util;

my $DAY = sprintf("%02d", 4);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../input/$INPUT_FILE");

say "Advent of Code 2023, Day 4: Scratchcards";

class ScratchCard {
	field $nums :param :reader;
	field $winning :param :reader;

	method matches() {
		my $set_1 = Set::Scalar->new(@{$nums});
		my $set_2 = Set::Scalar->new(@{$winning});
		my $i = $set_1->intersection($set_2);
		return $i->elements;
	}

	method points() {
		my $count = $self->matches();
		return 0 if $count < 1;
		return 2 ** ($count - 1);
	}

	sub from_str($cls, $str) {
		$str =~ m/: ([\d \|]+)/;
		my $trimmed = $1;
		$trimmed =~ s/^ //g;
		my @split_result = split(/ \| /, $trimmed);
		my @wins = split(/ +/, $split_result[0]);
		my @nums = split(/ +/, $split_result[1]);
		return $cls->new(nums => \@nums, winning => \@wins);
	}
}

my @cards = map {ScratchCard->from_str($_)} @input;

solve_part_one(@cards);
#solve_part_two(@input);

exit( 0 );

sub solve_part_one(@cards) {
	my @points = map { $_->points() } @cards;
	my $total = sum(@points);

	say "Part One: the total scratchcard points is $total.";
}

sub solve_part_two(@input) {

	say "Part One: ";
}
