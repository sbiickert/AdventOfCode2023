#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
#use Storable 'dclone';

use AOC::Util;
use AOC::Geometry;
#use AOC::Grid;

my $DAY = sprintf("%02d", 22);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 22: Sand Slabs";

my @bricks = parse_bricks(@input);
my @temp = map {$_->to_str()} @bricks;
p @temp;
@temp = map {$_->extent2D()->to_str()} @bricks;
p @temp;

solve_part_one(@bricks);
#solve_part_two(@input);

exit( 0 );

sub solve_part_one(@falling) {
	my @bricks = settle(@falling);
	my @temp = map {$_->to_str()} @bricks;
	p @temp;
	say "Part One: ";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub settle(@falling_bricks) {
	my @sorted = sort { $a->nwd()->Z() <=> $b->nwd()->Z() } @falling_bricks;
	my @plans = map {$_->extent2D()} @sorted;
	my @temp = map {$_->to_str()} @sorted;
	p @temp;

	for my $i (0..$#sorted) {
		my $brick = $sorted[$i];
		say $brick->to_str();
		my $plan = $plans[$i];
		my @below = grep { !$_->equals($brick) && $_->zmax() <= $brick->zmin() } @sorted;
		my @below_overlapping = grep { $_->extent2D()->overlaps($plan) } @below;
		if (scalar @below_overlapping) {
			my @temp = map {$_->to_str()} @below_overlapping;
			p @temp;
		}
		my $target_z = 0;
		if (scalar @below_overlapping > 0) {
			my @below_sorted = sort { $a->zmax() <=> $b->zmax() } @below_overlapping;
			$target_z = $below_sorted[-1]->zmax() + 1;
		}
		my $drop = $target_z - $brick->zmin();
		say "lowering $drop";
		my $offset = c3_make(0,0,$drop);
		my $settled_brick = e3_make($brick->nwd()->add($offset), $brick->seu()->add($offset));
		say $settled_brick->to_str();
		$sorted[$i] = $settled_brick;
		say '';
	}

	return @sorted;
}

sub parse_bricks(@input) {
	my @bricks = ();
	for my $line (@input) {
		my @min_max = split(/\~/, $line);
		my $min = c3_make(split(/,/, $min_max[0]));
		my $max = c3_make(split(/,/, $min_max[1]));
		my $brick = e3_make($min, $max);
		push(@bricks, $brick);
	}
	return @bricks;
}
