#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'all';

use AOC::Util;
use AOC::Geometry;
#use AOC::Grid;

my $DAY = sprintf("%02d", 22);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 22: Sand Slabs";

my @bricks = parse_bricks(@input);
my @settled = settle(@bricks);

my ($supporting_ref, $resting_on_ref) = determine_supporting(@settled);
my %supporting = %{$supporting_ref};
my %resting_on = %{$resting_on_ref};

my @nd = solve_part_one();
solve_part_two(@nd);

exit( 0 );

sub solve_part_one() {
	my @distintegrateable = ();
	my @not_distintegrateable = ();

	for my $i (keys %supporting) {
		my $can_disintegrate = 1;
		for my $j (@{$supporting{$i}}) {
			my @j_resting_on = @{$resting_on{$j}};
			if (scalar @j_resting_on == 1) {
				# the only brick that $j is resting on is $i
				$can_disintegrate = 0;
			}
		}
		if ($can_disintegrate) {
			push(@distintegrateable, $i);
		}
		else {
			push(@not_distintegrateable, $i);
		}
	}

	say "Part One: the number of disintegrateable bricks is " . scalar @distintegrateable;
	return @not_distintegrateable;
}

sub solve_part_two(@not_distintegrateable) {
	my $sum = 0;

	for my $i (@not_distintegrateable) {
		my $d_count = cascade($i);
		$sum += $d_count;
	}

	say "Part Two: the sum of all cascading disintegrations is $sum.";
}

sub cascade($i) {
	my %disintegrated = ($i => 1);
	my @next = ();
	push( @next, @{$supporting{$i}} );
	while (scalar @next > 0) {
		my $j = shift(@next);
		my $can_disintegrate_j = 0;
		if (scalar @{$resting_on{$j}} == 1) { $can_disintegrate_j = 1 }
		elsif (all { defined $disintegrated{$_} } @{$resting_on{$j}}) {
			$can_disintegrate_j = 1
		}
		if ($can_disintegrate_j) {
			$disintegrated{$j} = 1;
			push(@next, @{$supporting{$j}});
		}
	}
	return (scalar %disintegrated) - 1;
}

sub determine_supporting(@bricks) {
	my %supporting = ();
	my %resting_on = ();
	my @plans = map {$_->extent2D()} @bricks;

	for my $i (0..$#bricks) {
		$supporting{$i} = [];
		$resting_on{$i} = [];
	}

	for my $i (0..$#bricks-1) {
		my $brick = $bricks[$i];
		my $plan = $brick->extent2D();

		for my $j ($i+1..$#bricks) {
			my $other = $bricks[$j];
			my $other_plan = $plans[$j];
			if ($other->zmin() == $brick->zmax()+1 && $plan->overlaps($other_plan)) {
				push(@{$supporting{$i}}, $j);
				push(@{$resting_on{$j}}, $i);
			}
		}
	}
	return (\%supporting, \%resting_on);
}

sub settle(@falling_bricks) {
	my @sorted = sort { $a->nwd()->Z() <=> $b->nwd()->Z() } @falling_bricks;
	my @plans = map {$_->extent2D()} @sorted;

	for my $i (0..$#sorted) {
		my $brick = $sorted[$i];
		my $plan = $plans[$i];
		my @below = grep { !$_->equals($brick) && $_->zmax() <= $brick->zmin() } @sorted;
		my @below_overlapping = grep { $_->extent2D()->overlaps($plan) } @below;
		my $target_z = 0;
		if (scalar @below_overlapping > 0) {
			my @below_sorted = sort { $a->zmax() <=> $b->zmax() } @below_overlapping;
			$target_z = $below_sorted[-1]->zmax() + 1;
		}
		my $drop = $target_z - $brick->zmin();
		my $offset = c3_make(0,0,$drop);
		my $settled_brick = e3_make($brick->nwd()->add($offset), $brick->seu()->add($offset));
		$sorted[$i] = $settled_brick;
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
