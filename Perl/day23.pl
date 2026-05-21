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

# my %overlay = ($start->to_str() => 'S', $end->to_str() => 'E');
# $map->print(\%overlay);

solve_part_one();
#solve_part_two(@input);

exit( 0 );

sub solve_part_one(@input) {
	my %links = ();
	for my $intersection (values %intersections) {
		my @temp = get_links($intersection);
		$links{$intersection->to_str()} = \@temp;
	}
	p %links;
	say "Part One: ";
}

sub solve_part_two(@input) {

	say "Part Two: ";
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
	return @links;
}
