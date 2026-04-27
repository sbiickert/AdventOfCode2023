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

use AOC::Util;

my $DAY = sprintf("%02d", 19);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @inputs = read_grouped_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 19: Aplenty";

my %workflows = parse_workflows($inputs[0]);
my @parts = parse_parts($inputs[1]);

solve_part_one();
#solve_part_two(@input);

exit( 0 );

sub solve_part_one() {
	my @x = ();
	for my $part (@parts) {
		my $w_name = 'in';
		do {
			$w_name = eval_workflow($part, $w_name);
		} until $w_name eq 'A' || $w_name eq 'R';
		push(@x, $part->{'rating'}) if $w_name eq 'A';
	}

	my $total = sum @x;

	say "Part One: the sum of ratings of the accepted parts is $total.";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub eval_workflow($part, $workflow_name) {
	my $result = '';
	my @steps = @{$workflows{$workflow_name}};
	for my $step (@steps) {
		if ($step =~ m/([xmas])([<>])(\d+):(\w+)/) {
			$result = eval_step($part->{$1},$2,$3,$4);
		}
		else { $result = $step; }
		last if $result ne '';
	}
	return $result;
}

sub eval_step($v1, $op, $v2, $next) {
	my $ok = ($op eq '<') ? ($v1 < $v2) : ($v1 > $v2);
	return $next if $ok;
}

sub parse_workflows($input) {
	my %w = ();
	for my $line (@{$input}) {
		$line =~ m/(\w+)\{(.+)\}/;
		my $name = $1;
		my @steps = split(/,/, $2);
		$w{$name} = \@steps;
	}
	return %w;
}

sub parse_parts($input) {
	my @p = ();
	for my $line (@{$input}) {
		$line =~ m/\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}/;
		my %part = ('x' => $1, 'm' => $2, 'a' => $3, 's' => $4);
		$part{'src'} = $line;
		$part{'rating'} = $1 + $2 + $3 + $4;
		push( @p, \%part );
	}
	return @p;
}
