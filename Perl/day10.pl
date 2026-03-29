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

my @input = read_grouped_input("../Input/$INPUT_FILE", $INPUT eq 'challenge' ? 0 : 5);

say "Advent of Code 2023, Day 10: Pipe Maze";

my ($grid, $start) = load_grid(@input);

solve_part_one();
# $grid->print();
solve_part_two();
# $grid->print();

exit( 0 );

sub solve_part_one() {
	my $steps = 0;
	my $pipe = $grid->get($start);
	$pipe->set_is_in_loop(1); # Prep for Part 2
	my @positions = map {p2_make($start, $_)} @{$pipe->open_dirs()};
	do {
		for my $idx (0..1) {
			my $next_pos = move_forward($positions[$idx]);
			$pipe = $grid->get($next_pos->coord());
			$pipe->set_is_in_loop(1); # Prep for Part 2
			$positions[$idx] = $next_pos;
		}
		$steps++;
		#say "$steps: " . join( ' ', map {$_->to_str()} @positions);
	} until ($positions[0]->coord()->equals($positions[1]->coord()) );

	say "Part One: the number of steps to reach the farthest point is $steps";
}

sub solve_part_two(@input) {
	remove_all_pipes_not_in_loop();
	my $start = find_pt2_start();
	my $pos = $start->clone();

	do {
		# Anything to the right is "inside"
		for my $c (coords_to_the_right($pos)) {
			#say $pos->coord()->to_str() . " " . $c->to_str();
			if ($grid->get_scalar($c) eq '.') {
				# Flood fill with 'I'
				$grid->flood_fill($c, 'I');
			}
		}
		$pos = move_forward($pos);
	} until ($pos->equals($start));

	my @inside_coords = $grid->coords('I');
	my $count = scalar @inside_coords;

	say "Part Two: the number of coords inside is $count";
}

sub move_forward($pos) {
	my $next_pos = $pos->move_forward();
	my $next_pipe = $grid->get($next_pos->coord());
	my $opp_dir = d2_opposite($next_pos->dir());
	my $next_dir = first { $_ ne $opp_dir } @{$next_pipe->open_dirs()};
	return p2_make($next_pos->coord(), $next_dir);
}

sub remove_all_pipes_not_in_loop() {
	for my $c ($grid->coords()) {
		if ($grid->get_scalar($c) eq '*') {
			$grid->clear($c);
		}
	}
	$grid->reset_extent();
}

sub coords_to_the_right($pos) {
	my $c = $pos->coord();
	my $d = $pos->dir(); # move_forward already "turned" $pos, so keep that in mind
	my $pipe = $grid->get($c);
	my $entry_dir = $pipe->entry_direction($d);

	my @check_coords = ();
	if ($entry_dir eq $d) {
		#straight, need to see if open spot to the right
		push(@check_coords, p2_make($c, d2_turn($d, 90)));
	}
	elsif($d eq d2_turn($entry_dir, -90)) {
		#left turn, need to see if open spots to the right, diagonal back right and back
		push(@check_coords, p2_make($c, d2_turn($d, 90)));
		push(@check_coords, p2_make($c, d2_turn($d, 135)));
		push(@check_coords, p2_make($c, d2_turn($d, 180)));
	}

	my @coords = ();
	for my $check (@check_coords) {
		my $offset_pos = $check->move_forward();
		push(@coords, $offset_pos->coord());
	}
	#say join(' ', $pos->to_str(), $pipe->glyph(), map {$_->to_str()} @coords);
	return @coords;
}

sub find_pt2_start() {
	my $ext = $grid->extent();
	my $start;
	for my $row ($ext->nw()->Y()..$ext->se()->Y()) {
		for my $col ($ext->nw()->X()..$ext->se()->X()) {
			my $c = c2_make($col, $row);
			my $glyph = $grid->get_scalar($c);
			if ($glyph eq '-') {
				$start = p2_make($c, '>');
				last;
			}
		}
		last if defined $start;
	}
	return $start;
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
	field $is_in_loop :reader :writer = 0;

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

	method entry_direction($exit_dir) {
		use AOC::Geometry;
		use List::Util 'first';
		my $enter = first {$_ ne $exit_dir} @{$open_dirs};
		return d2_opposite($enter);
	}

	method exit_direction($enter_dir) {
		use AOC::Geometry;
		use List::Util 'first';
		my $opp_enter = d2_opposite($enter_dir);
		return first {$_ ne $opp_enter} @{$open_dirs};
	}

	method glyph() {
		return 'S' if $animal;
		return '*' if !$is_in_loop;
		return $glyph;
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
