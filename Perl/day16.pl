#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
#use Data::Printer;
#use Storable 'dclone';

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
#solve_part_two(@input);

exit( 0 );

sub solve_part_one($grid) {
	my @beams = (p2_make( c2_origin, "E"));
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

	say "Part One: the total number of energized squares is $energized_count.";
}

sub solve_part_two(@input) {

	say "Part Two: ";
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
