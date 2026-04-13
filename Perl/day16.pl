#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
#use Data::Printer;
use List::Util 'max';

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 16);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 16: The Floor Will Be Lava";

my $grid = g2_make();
$grid->load(@input);

solve_part_one($grid);
solve_part_two($grid);

exit( 0 );

sub solve_part_one($grid) {
	my $beam = (p2_make( c2_origin, "E"));
	my $energized_count = count_energized_squares($grid, $beam);
	say "Part One: the total number of energized squares is $energized_count.";
}

sub solve_part_two($grid) {
	my @counts = ();

	my $ext = $grid->extent();
	my $xmax = $ext->se()->X();
	my $ymax = $ext->se()->Y();

	for my $col (0..$xmax) {
		my $north_edge_beam = p2_make( c2_make( $col, 0 ), "S");
		push(@counts, count_energized_squares($grid, $north_edge_beam));
		my $south_edge_beam = p2_make( c2_make( $col, $ymax ), "N");
		push(@counts, count_energized_squares($grid, $south_edge_beam));
	}

	for my $row (0..$ymax) {
		my $west_edge_beam = p2_make( c2_make( 0, $row ), "E");
		push(@counts, count_energized_squares($grid, $west_edge_beam));
		my $east_edge_beam = p2_make( c2_make( $xmax, $row ), "W");
		push(@counts, count_energized_squares($grid, $east_edge_beam));
	}

	my $max = max @counts;
	say "Part Two: the maximum number of energized squares is $max.";
}

sub count_energized_squares($grid, $beam) {
	my @beams = ($beam);
	my %energized = ();
	my %memo = ();
	my $ext = $grid->extent();

	while (scalar @beams > 0) {
		my @moved_beams = ();
		for my $beam (@beams) {
			$energized{$beam->coord()->to_str()} = 1;
			$memo{$beam->to_str()} = 1;

			my @results = move_beam($beam, $grid);

			for my $moved_beam (@results) {
				if (defined $memo{$moved_beam->to_str()}) { next }
				if ($ext->contains($moved_beam->coord())) {
					push(@moved_beams, $moved_beam);
				}
			}
		}

		@beams = @moved_beams;
	}
	my $energized_count = scalar %energized;
	return $energized_count;
}

sub move_beam($beam, $grid) {
	my $dir = $beam->dir();
	my $coord = $beam->coord();
	my $grid_value = $grid->get($coord);

	if ($grid_value eq '.') {
		return $beam->move_forward();
	}
	if (($grid_value eq '|') && ($dir eq 'N' || $dir eq 'S')) {
		return ($beam->move_forward());
	}
	if (($grid_value eq '-') && ($dir eq 'W' || $dir eq 'E')) {
		return ($beam->move_forward());
	}
	if (($grid_value eq '-') && ($dir eq 'N' || $dir eq 'S')) {
		return ($beam->turn('CW')->move_forward(), $beam->turn('CCW')->move_forward());
	}
	if (($grid_value eq '|') && ($dir eq 'W' || $dir eq 'E')) {
		return ($beam->turn('CW')->move_forward(), $beam->turn('CCW')->move_forward());
	}
	if ($dir eq 'N' || $dir eq 'S') {
		if ($grid_value eq "\\") { return ($beam->turn('CCW')->move_forward()) }
		if ($grid_value eq "/")  { return ($beam->turn('CW')->move_forward()) }
	}
	if ($dir eq 'W' || $dir eq 'E') {
		if ($grid_value eq "\\") { return ($beam->turn('CW')->move_forward()) }
		if ($grid_value eq "/")  { return ($beam->turn('CCW')->move_forward()) }
	}
	return ();
}
