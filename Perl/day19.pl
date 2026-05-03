#!/usr/bin/env perl
use v5.42;
use feature 'class';
no warnings qw( experimental::class );

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

my %workflows = parse_workflows(@{$inputs[0]});
my @parts = parse_parts(@{$inputs[1]});

solve_part_one();
#solve_part_two(@input);

exit( 0 );

sub solve_part_one() {
	my @accepted_ratings = ();
	for my $part (@parts) {
		my $w_name = 'in';

		do {
			my $workflow = $workflows{$w_name};
			$w_name = $workflow->evaluate($part);
		} until $w_name eq 'A' || $w_name eq 'R';

		push(@accepted_ratings, $part->rating()) if $w_name eq 'A';
	}

	my $total = sum @accepted_ratings;

	say "Part One: the sum of ratings of the accepted parts is $total.";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub parse_workflows(@input) {
	my @list = map { Workflow->new(src => $_) } @input;
	my %result = ();
	for my $w (@list) {
		$result{$w->name} = $w;
	}
	return %result;
}

sub parse_parts(@input) {
	my @list = map { WeirdMetalShape->new(src => $_) } @input;
	return @list;
}


class WeirdMetalShape {
	field $src :param :reader;
	field $x :reader;
	field $m :reader;
	field $a :reader;
	field $s :reader;

	ADJUST {
		$src =~ m/\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}/;
		$x = $1; $m = $2; $a = $3; $s = $4;
	}

	method rating() {
		return $x + $m + $a + $s;
	}

	method value($key) {
		return $x if $key eq 'x';
		return $m if $key eq 'm';
		return $a if $key eq 'a';
		return $s if $key eq 's';
		return 0;
	}
}

class WorkflowCondition {
	field $src :param :reader;
	field $key :reader;
	field $relation :reader;
	field $value :reader;

	ADJUST {
		if ($src =~ m/([xmas])([<>])(\d+)/) {
			$key = $1;
			$relation = $2;
			$value = $3;
		}
		else {
			$key = "";
			$relation = "";
			$value = 0;
		}
	}

	method evaluate($input) {
		if ($relation eq '<') { return $input < $value }
		if ($relation eq '<=') { return $input <= $value }
		if ($relation eq '>') { return $input > $value }
		if ($relation eq '>=') { return $input >= $value }
		return 1;
	}

	method negated() {
		my $opposite;
		if ($relation eq '<') { $opposite = '>=' }
		if ($relation eq '<=') { $opposite = '>' }
		if ($relation eq '>') { $opposite = '<=' }
		if ($relation eq '>=') { $opposite = '<' }
		return WorkflowCondition->new(src => "$key$opposite$value");
	}

	sub combine($cls, @conditions) {
		return 4000 if scalar(@conditions == 0);
		use List::Util qw( min max );
		my $low = 0;
		my $high = 4000;

		for my $cond (@conditions) {
			if ($cond->relation() eq '<') {
				$high = min($high, $cond->value() - 1);
			}
			elsif ($cond->relation() eq '<=') {
				$high = min($high, $cond->value());
			}
			elsif ($cond->relation() eq '>') {
				$low = max($low, $cond->value());
			}
			elsif ($cond->relation() eq '>=') {
				$low = max($low, $cond->value() - 1);
			}
		}
		return $high - $low;
	}
}

class WorkflowRule {
	field $src :param :reader;
	field $condition :reader;
	field $target :reader;

	ADJUST {
		my @parts = split(/:/, $src);
		if (scalar(@parts) == 1) {
			$target = $src;
		}
		else {
			$condition = WorkflowCondition->new(src => $parts[0]);
			$target = $parts[1];
		}
	}

	method evaluate($wms) {
		if (defined $condition) {
			return $target if $condition->evaluate($wms->value($condition->key()));
			return '';
		}
		return $target;
	}

}

class Workflow {
	field $src :param :reader;
	field $name :reader;
	field $rules = [];

	ADJUST {
		$src =~ m/(\w+)\{(.+)\}/;
		$name = $1;
		my @parts = split(/,/, $2);
		my @rules = ();
		for my $rule_src (@parts) {
			push(@rules, WorkflowRule->new(src => $rule_src));
		}
		$rules = \@rules;
	}

	method evaluate($wms) {
		for my $rule (@{$rules}) {
			my $result = $rule->evaluate($wms);
			return $result if $result ne '';
		}
	}
}
