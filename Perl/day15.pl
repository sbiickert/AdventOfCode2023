#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use List::Util 'sum';

use AOC::Util;

my $DAY = sprintf("%02d", 15);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 15: Lens Library";

my @steps = split(/,/, $input[0]);
solve_part_one(@steps);
solve_part_two(@steps);

exit( 0 );

sub solve_part_one(@steps) {
	my @values = map {hash_string($_)} @steps;
	my $total = sum @values;

	say "Part One: the sum of the hash results is $total.";
}

sub solve_part_two(@steps) {
	my @boxes = ();
	for my $i (0..255) { push(@boxes, []) };

	for my $step (@steps) {
		if ($step =~ m/(\w+)=(\d+)/) {
			my $label = $1;
			my $fl = $2;
			my $box_number = hash_string($label);
			my $box = $boxes[$box_number];
			my %lens = ('label' => $label, 'focal_length' => $fl);
			my $b_found_same_label = 0;
			for my $i (0..$#{$box}) {
				if ($box->[$i]{'label'} eq $lens{'label'}) {
					$box->[$i] = \%lens;
					$b_found_same_label = 1;
					last;
				}
			}
			if (!$b_found_same_label) {
				push(@{$box}, \%lens);
			}
		}

		elsif ($step =~ m/(\w+)-/) {
			my $label = $1;
			my $box_number = hash_string($label);
			my $box = $boxes[$box_number];
			for my $i (0..$#{$box}) {
				if ($box->[$i]{'label'} eq $label) {
					splice(@{$box}, $i, 1);
					last;
				}
			}
		}
	}

	my @focusing_powers = ();
	for my $i (0..$#boxes) {
		push(@focusing_powers, calc_focusing_power($boxes[$i], $i+1));
	}
	my $total = sum(@focusing_powers);

	say "Part Two: the total focusing power is $total.";
}

sub calc_focusing_power($box_ref, $index) {
	my @box = @{$box_ref};
	if (scalar @box == 0) {return 0}
	my @powers = ();
	for my $i (0..$#box) {
		my $fp = $index * ($i+1) * $box[$i]{'focal_length'};
		push(@powers, $fp);
	}
	return sum @powers;
}

sub hash_string($str) {
	my $value = 0;
	for my $char (split(//, $str)) {
		my $ascii = ord($char);
		$value = (($value + $ascii) * 17) % 256;
	}
	return $value;
}
