#!/usr/bin/env perl
use v5.40;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
#use Storable 'dclone';
use List::Util 'sum';

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 3);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../input/$INPUT_FILE");

say "Advent of Code 2023, Day 3: Gear Ratios";

my $schematic = g2_make('.', QUEEN());
$schematic->load(@input);
# $schematic->print();

my @all_symbols = get_unique_symbols(@input);
say @all_symbols;

solve_part_one();
#solve_part_two();

exit( 0 );

sub solve_part_one() {
	my @all_numbers = ();
	for my $sym (@all_symbols) {
		my @numbers = find_numbers($sym);
		push(@all_numbers, @numbers);
	}
	my $sum_numbers = sum(@all_numbers);

	say "Part One: the total of the part IDs is $sum_numbers";
}

sub solve_part_two(@input) {

	say "Part One: ";
}

sub get_unique_symbols(@input) {
	my %hash = ();
	for my $line (@input) {
		for my $char (split(//, $line)) {
			if ($char =~ m/[^\d\.]/) {
				$hash{$char} = 1;
			}
		}
	}
	my @result = keys %hash;
	return @result;
}

sub find_numbers($symbol) {
	my @result = ();
	my @coords = $schematic->coords($symbol);
	for my $coord (@coords) {
		my @neighbors = $schematic->neighbors($coord);
		my %numbers = ();
		for my $n (@neighbors) {
			my $val = $schematic->get_scalar($n);
			if ($val =~ m/\d/) {
				$numbers{get_part_id($n)} = 1;
			}
		}
		push(@result, keys %numbers);
	}
	return @result;
}

sub get_part_id($coord) {
	# $coord contains a digit.
	# Work left until does not (start of part ID)
	# then move right until it does not (end of part ID)
	my $ptr = $coord;
	do {
		$ptr = $ptr->offset('<');
	} until ($schematic->get_scalar($ptr) =~ m/[^\d]/);
	$ptr = $ptr->offset('>');
	my @digits = ();
	while ($schematic->get_scalar($ptr) =~ m/[\d]/) {
		push(@digits, $schematic->get_scalar($ptr));
		$ptr = $ptr->offset('>');
	}
	return join('', @digits);
}
