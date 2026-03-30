#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'sum';
use Math::Combinatorics;

use AOC::Util;

my $DAY = sprintf("%02d", 12);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 12: Hot Springs";

my @records = parse_records(@input);
# p @records;

solve_part_one(@records);
#solve_part_two(@input);

exit( 0 );

sub solve_part_one(@records) {
	my @counts = map { get_arr_count( %{$_} ) } @records;
	my $arr_count = sum(@counts);
	say "Part One: the total number of possible arrangements is $arr_count.";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub get_arr_count(%record) {
	my @q_marks = grep { $_ eq '?' } @{$record{'status'}};
	my $q_count = scalar @q_marks;
	my @broken = grep { $_ eq '#' } @{$record{'status'}};
	my $broken_count = scalar @broken;
	my $expected_broken_count = sum(@{$record{'groups'}});
	my $missing_broken_count = $expected_broken_count - $broken_count;
	my $missing_working_count = $q_count - $missing_broken_count;

	my @opts = ( '.', '#' );
	my @freq = ($missing_working_count, $missing_broken_count);

	my $count = 0;
	my $combinat = Math::Combinatorics->new(frequency => \@freq, data => \@opts);
	while (my @combo = $combinat->next_string) {
		my $s = join('', @{$record{'status'}});
		while (my $char = pop(@combo)) { $s =~ s/\?/$char/; }
		if ($s =~ m/$record{'regex'}/) {
			$count++;
		}
	}
	say $count;
	return $count;
}

sub parse_records(@input) {
	my @recs = ();
	for my $line (@input) {
		my @parts = split(/ /, $line);
		my @status = split(//, $parts[0]);
		my @groups = split(/,/, $parts[1]);
		my %info = ('status' => \@status, 'groups' => \@groups, 'regex' => mk_regex(@groups));
		push(@recs, \%info);
	}
	return @recs;
}

sub mk_regex(@groups) {
	my @temp = map {"#{$_}"} @groups;
	return join('\.+', @temp);
}
