#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'any', 'max';

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 23);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 23: A Long Walk";

my $w = (length $input[0]) - 1;
my $h = $#input;
my $map = g2a_make($w, $h);
$map->load(@input);
my $extent = $map->extent();
my $start = c2_make(1, 0);
my $end = c2_make($w - 1, $h);
my %intersections = find_intersections();

my %links = ();
for my $intersection (values %intersections) {
	my @temp = get_links($intersection);
	$links{$intersection->to_str()} = \@temp;
}

my %memo;

solve_part_one();
solve_part_two();

exit( 0 );

sub solve_part_one() {
	%memo = ();
	my $length = find_longest($start->to_str(), 0, 0, ());
	say "Part One: the longest path is $length long.";
}

sub solve_part_two(@input) {
	%memo = ();
	my $length = find_longest($start->to_str(), 0, 1, ());
	say "Part Two: the longest path allowing uphill travel is $length long.";
}


sub find_longest($int_id, $length, $allow_uphill, @path) {
	return $length if $int_id eq $end->to_str();
# 	return $memo{$int_id} if defined $memo{$int_id};

	my $longest = 0;
	for my $link (@{$links{$int_id}}) {
		# Don't try going uphill if not allowed (pt 1)
		next if (!$allow_uphill && $link->{'slope'} eq 'up');
		# Don't return to any previous intersection
		next if any {$_ eq $link->{'to'}} @path;

		my @new_path = (@path, $link->{'from'});
		my $l = find_longest($link->{'to'},
							 $length + $link->{'length'},
							 $allow_uphill,
							 @new_path);
		$longest = max ($longest, $l);
	}

	$memo{$int_id} = $longest;
	return $longest;
}

sub find_intersections() {
	my %result = ($start->to_str() => $start, $end->to_str() => $end);
	for my $x (0..$w) {
		for my $y (0..$h) {
			if ($map->get_xy($x, $y) ne '#') {
				my @dirs = get_open_directions($x, $y);
				if (scalar @dirs > 2) {
					my $intersection = c2_make($x, $y);
					$result{$intersection->to_str()} = $intersection;
				}
			}
		}
	}
	return %result;
}

sub get_open_directions($x, $y) {
	my @result = ();
	my $c = c2_make($x, $y);
	my ($nx, $ny) = $map->neighbors_xy($x, $y);
	my @nx = @{$nx}; my @ny = @{$ny};
	for my $i (0..$#nx) {
		my $n_val = $map->get_xy($nx[$i], $ny[$i]);
		if ($n_val ne '#' && $extent->contains_xy($nx[$i], $ny[$i])) {
			push(@result, d2_to($c, c2_make($nx[$i], $ny[$i])));
		}
	}
	return @result;
}

sub get_links($intersection) {
# 	say $intersection->to_str();
	my @dirs = get_open_directions($intersection->X(), $intersection->Y());
# 	say @dirs;
	my @links = ();
	for my $dir (@dirs) {
# 		say $dir;
		my $length = 0;
		my $slope = 'flat';
		my $pos = p2_make($intersection, $dir);
		do {
			$pos = $pos->move_forward();
			my $l = $pos->left_coord();
			my $r = $pos->right_coord();
			if 		($map->get($l) ne '#') 	{ $pos = $pos->turn('CCW') }
			elsif 	($map->get($r) ne '#') 	{ $pos = $pos->turn('CW') }
			$length++;
			my $here = $map->get($pos->coord());
			if ($here ne '.') {
				my $resolved = d2_from_alias($here);
				$slope = $resolved eq $pos->dir() ? 'down' : 'up';
			}
# 			say $pos->coord()->to_str();
		} until (defined $intersections{$pos->coord()->to_str()});
		my %link = ('id' => $intersection->to_str() . '->' . $pos->coord()->to_str(),
					'from' => $intersection->to_str(),
					'to' => $pos->coord()->to_str(),
					'length' => $length,
					'slope' => $slope);
		push(@links, \%link);
	}
	@links = sort {$b->{'length'} <=> $a->{'length'}} @links;
	return @links;
}
