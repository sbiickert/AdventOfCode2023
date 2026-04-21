#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;

use AOC::Util;
use AOC::Geometry;
use AOC::Grid;

my $DAY = sprintf("%02d", 17);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @inputs = read_grouped_input("../Input/$INPUT_FILE");

say "Advent of Code 2023, Day 17: Clumsy Crucibles";

my $city = g2a_make(length($inputs[0][0]) - 1, $#{$inputs[0]});
$city->load(@{$inputs[0]});
# $city->print();

solve_part_one($city);
#solve_part_two(@input);

exit( 0 );

sub solve_part_one($city) {
	my %start = ('dir' => 'E', 'run' => 1, 'loss' => 0, 'id' => '0');

	my $best = 800;
	my $best_id;
	my $dest_x = $city->x_max();
	my $dest_y = $city->y_max();
	my $loss_at_destination = $city->get_xy($dest_x, $dest_y);

	# Set up grid for tracking results
	my $grid = g2a_make($dest_x, $dest_y);
	my ($xs, $ys) = $grid->xy();
	for my $i (0..$#{$xs}) {
		my %empty = ();
		$grid->set_xy($xs->[$i], $ys->[$i], \%empty);
	}
	my $ref = $grid->get_xy(0, 0);
	my $key = $start{'dir'} . " " . $start{'run'};
	$ref->{$key} = \%start;

	my @work = ([0,0,0]); # x,y,loss
	while (scalar(@work) > 0) {
		my @next_work = ();
		while (my $job = pop(@work)) {
			my $x = $job->[0]; my $y = $job->[1]; my $loss = $job->[2];

			if ($x == $dest_x && $y == $dest_y) {
				if ($loss < $best) {
					$best = $loss ;
					$best_id = $job->[3];
					say $best;
				}
				next;
			}
			my $heur = (2.5 * ($dest_x - $x) + ($dest_y -$y));
			next if $loss >= $best - $heur;

# 			say "$x, $y";
			my @states = values %{$grid->get_xy($x, $y)};
			for my $state (@states) {
				my $id = $state->{'id'};
				my $state_job = [$x, $y, $state->{'loss'}, $id];
				# Go straight
				if ($state->{'run'} < 3) {
					my $new_job = eval_dir($state->{'dir'}, $city, $grid, $state->{'run'}, $state_job, $id);
					if (defined $new_job) {
						push( @next_work, $new_job);
					}
				}
				# Turn left
				my $dir_ccw = Position->turn_str("CCW", $state->{'dir'});
				my $new_ccw_job = eval_dir($dir_ccw, $city, $grid, 0, $state_job, $id);
				if (defined $new_ccw_job) {
					push( @next_work, $new_ccw_job);
				}

				# Turn right
				my $dir_cw = Position->turn_str("CW", $state->{'dir'});
				my $new_cw_job = eval_dir($dir_cw, $city, $grid, 0, $state_job, $id);
				if (defined $new_cw_job) {
					push( @next_work, $new_cw_job);
				}
			}
		}
# 		p @work;
# 		my $pause = <STDIN>;
		@work = sort { $a->[0] + $a->[1] <=> $b->[0] + $b->[1] } @next_work; # ascending by manhattan distance from start
# 		say "----";
		@next_work = ();
	}

# 	say $best_id;
# 	my %markers = mk_debug_markers($grid, $best_id);
# 	p %markers;
# 	$city->print(\%markers);

	say "Part One: the least heat loss is $best.";
}

my $next_id = 0;
sub get_next_id() { return ++$next_id }

sub eval_dir($dir, $city, $grid, $run, $job, $id) {
	my @offset = xy_offset($dir);
	my $off_x = $job->[0] + $offset[0];
	my $off_y = $job->[1] + $offset[1];

	my $new_job;
	if ($off_x >= 0 && $off_x <= $city->x_max() &&
		$off_y >= 0 && $off_y <= $city->y_max()) {
		my $loss = $job->[2];
		my $loss_at_offset = $city->get_xy($off_x, $off_y);
		my $new_id = $id . ',' . get_next_id;
		$new_job = [$off_x, $off_y, $loss + $loss_at_offset, $new_id];
		my %new_state = ('dir' => $dir,
						 'run' => $run+1,
						 'loss' => $loss + $loss_at_offset,
						 'id' => $new_id);

		my $ref = $grid->get_xy($off_x, $off_y);
		my $key = "$dir " . ($run + 1);
		if (defined $ref->{$key}) {
			# Have re-entered a block from the same direction
			if ($loss + $loss_at_offset < $ref->{$key}{'loss'}) {
				$ref->{$key} = \%new_state;
			}
			else {
				$new_job = undef;
			}
		}
		else {
			$ref->{$key} = \%new_state;
		}
	}
	return $new_job;
}

sub mk_debug_markers($grid, $best_id) {
	my %markers = ();

	my @ids = split(/,/, $best_id);
	my %id_lookup = ();
	while ( scalar(@ids) > 0 ) {
		my $id = join(',', @ids);
		$id_lookup{$id} = 1;
		pop(@ids);
	}
	p %id_lookup;
	my %char_map = ('S' => 'v', 'N' => '^', 'W' => '<', 'E' => '>');

	my @coords = $grid->coords();
	for my $id (keys %id_lookup) {
		for my $c (@coords) {
			my @states = values %{$grid->get($c)};
			for my $state (@states) {
				if (defined $id_lookup{$state->{'id'}}) {
					$markers{$c->to_str()} = $char_map{ $state->{'dir'} };
				}
			}
		}
	}

	return %markers;
}

sub solve_part_two(@input) {

	say "Part Two: ";
}
