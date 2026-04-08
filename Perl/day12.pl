#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util qw(any sum);
use Math::Combinatorics;

use AOC::Util;

my $DAY = sprintf("%02d", 12);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 12: Hot Springs";

my @records = parse_records(1, @input);
# p @records;
solve_part_one(@records);

@records = parse_records(5, @input);
solve_part_two(@records);

exit( 0 );

sub solve_part_one(@records) {
	my @counts = map { get_possible_arrangement_count( $_ ) } @records;
	my $arr_count = sum(@counts);
	say "Part One: the total number of possible arrangements is $arr_count.";
}

sub solve_part_two(@input) {
	my @counts = map { get_possible_arrangement_count( $_ ) } @records;
	my $arr_count = sum(@counts);
	say "Part Two: the total number of possible unfolded arrangements is $arr_count.";
}

my %memo = ();
sub get_possible_arrangement_count($record) { # hash ref
	%memo = ();
	my $count = get_arr_count($record, 0, 0);
	return $count;
}

sub get_arr_count($record, $p, $g) {
	my @groups = @{$record->{'groups'}};
	my @status = @{$record->{'status'}};
	if ($g >= scalar @groups) { # no more groups
		if ($p < $#status and (any {$_ eq '#'} @status[$p..$#status])) {
			return 0; # not a solution - there are still damaged springs in the record
		}
		return 1;
	}

	my $g_length = $groups[$g];
	if ($p + $g_length > scalar @status) {
		return 0; # we ran out of springs but there are still groups to arrange
	}

	my $memo_key = "$p,$g";
	if (exists $memo{$memo_key}) { return $memo{$memo_key}; }

	my $result = 0;

	if ($status[$p] eq '?') {
		# if we can start group of damaged springs here
		# eg: '??#...... 3' we can place 3 '#' and there is '?' or '.' after the group
		# eg: '??##...... 3' we cannot place 3 '#' here
		my $b_no_operational = !any {$_ eq '.'} @status[$p..$p+$g_length-1];
		no warnings 'uninitialized';
		my $b_next_not_broken = $status[$p + $g_length] ne "#";
		use warnings 'uninitialized';
		if ($b_no_operational and $b_next_not_broken) {
			# start damaged group here + this spring is operational ('.')
			$result = get_arr_count($record, $p + $g_length + 1, $g + 1) +
				get_arr_count($record, $p + 1, $g);
		}
		else {
			# This spring is operational
			$result = get_arr_count($record, $p+1, $g);
		}
	}
	elsif ($status[$p] eq '#') {
		# if we can start damaged group here
		my $b_no_operational = !any {$_ eq '.'} @status[$p..$p+$g_length-1];
		no warnings 'uninitialized';
		my $b_next_not_broken = ($status[$p + $g_length] ne "#");
		use warnings 'uninitialized';
		if ($b_no_operational and $b_next_not_broken) {
			$result = get_arr_count($record, $p + $g_length + 1, $g + 1);
		}
		else {
			$result = 0; # not a solution - we must always start damaged group here
		}
	}
	elsif ($status[$p] eq '.') {
		# operational spring -> go to the next spring
		$result = get_arr_count($record, $p + 1, $g);
	}

	$memo{$memo_key} = $result;
	return $result;
}

sub parse_records($folds, @input) {
	my @recs = ();
	for my $line (@input) {
		my @parts = split(/ /, $line);
		my $status_str = join('?', ($parts[0]) x $folds);
		my @status = split(//, $status_str);
		push(@status, '.');
		my $group_str = join(',', ($parts[1]) x $folds);
		my @groups = split(/,/, $group_str);
		my %info = ('status' => \@status, 'groups' => \@groups);
		push(@recs, \%info);
	}
	return @recs;
}
