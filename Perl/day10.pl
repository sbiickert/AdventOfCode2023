#!/usr/bin/env perl
use v5.42;
use feature 'class';
no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'first';

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 10);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_grouped_input("../input/$INPUT_FILE", $INPUT eq 'challenge' ? 0 : 1);

say "Advent of Code 2023, Day 10: Pipe Maze";

my ($grid, $start) = load_grid(@input);
$grid->print();

solve_part_one();
#solve_part_two(@input);

exit( 0 );

sub solve_part_one() {
	my $steps = 0;
	my $pipe = $grid->get($start);
	my @positions = map {p2_make($start, $_)} @{$pipe->open_dirs()};
	#say "$steps: " . join( ' ', map {$_->to_str()} @positions);
	do {
		for my $idx (0..1) {
			my $next_pos = $positions[$idx]->move_forward();
			my $next_pipe = $grid->get($next_pos->coord());
			my $opp_dir = d2_opposite($next_pos->dir());
			my $next_dir = first { $_ ne $opp_dir } @{$next_pipe->open_dirs()};
			$positions[$idx] = p2_make($next_pos->coord(), $next_dir);
		}
		$steps++;
		#say "$steps: " . join( ' ', map {$_->to_str()} @positions);
	} until ($positions[0]->coord()->equals($positions[1]->coord()) );

	say "Part One: the number of steps to reach the farthest point is $steps";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}

sub load_grid(@input) {
	my $g = g2_make();
	$g->load(@input);
	for my $coord ($g->coords()) {
		my $str = $g->get_scalar($coord);
		if ($str ne 'S') {
			$g->set($coord, Pipe->new(glyph => $str, loc => $coord));
		}
	}
	# Place the correct pipe for the animal
	my @coords = $g->coords('S');
	my $c = $coords[0];
	my @open = ();
	for my $dir (d2_for_rule($g->rule())) {
		my $neighbor = $c->offset($dir);
		if ($g->get_scalar($neighbor) ne '.') {
			my $n_pipe = $g->get($neighbor);
			if ($n_pipe->is_open_to( d2_opposite($dir) )) {
				push(@open, $dir);
			}
		}
	}
	my $animal_pipe = Pipe->new( glyph => Pipe->glyph_from_dirs( @open ),
								 loc => $c,
								 animal => 1);
	$g->set($c, $animal_pipe);
	return $g, $c;
}

class Pipe {
	field $glyph :param;
	field $loc :param :reader;
	field $open_dirs :reader;
	field $animal :param :reader :writer = 0;

	ADJUST {
		use AOC::Geometry;
		if ($glyph eq '|')		{ $open_dirs = [d2_from_alias('^'), d2_from_alias('v')] }
		elsif ($glyph eq '-')	{ $open_dirs = [d2_from_alias('<'), d2_from_alias('>')] }
		elsif ($glyph eq 'L')	{ $open_dirs = [d2_from_alias('^'), d2_from_alias('>')] }
		elsif ($glyph eq 'J')	{ $open_dirs = [d2_from_alias('<'), d2_from_alias('^')] }
		elsif ($glyph eq '7')	{ $open_dirs = [d2_from_alias('<'), d2_from_alias('v')] }
		elsif ($glyph eq 'F')	{ $open_dirs = [d2_from_alias('v'), d2_from_alias('>')] }
		else { $open_dirs = [] }
	}

	method is_open_to($dir) {
		return (List::Util::any {$_ eq $dir} @{$open_dirs});
	}

	method glyph() {
		return $animal ? 'S' : $glyph;
	}

	sub glyph_from_dirs($cls, @dirs) {
		my $dir_str = join('', sort @dirs);
		return '|' if $dir_str eq "NS";
		return '-' if $dir_str eq "EW";
		return 'L' if $dir_str eq "EN";
		return 'J' if $dir_str eq "NW";
		return '7' if $dir_str eq "SW";
		return 'F' if $dir_str eq "ES";
		return '!';
	}
}
