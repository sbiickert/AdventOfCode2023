#!/usr/bin/env perl
use v5.42;

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use Heap::PQ;

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

my $p1 = solve_part($city, 1, 3);
say "Part One: the least heat loss is $p1.";
my $p2 = solve_part($city, 4, 10);
say "Part Two: the least heat loss is $p2.";

exit( 0 );

sub solve_part($city, $min_run, $max_run) {
	my %start = ('dir' => 'E', 'run' => 1, 'loss' => 0, 'id' => '0');

	my $best = 1000;
	my $best_id;
	my $dest_x = $city->x_max();
	my $dest_y = $city->y_max();
	my $loss_at_destination = $city->get_xy($dest_x, $dest_y);

	my $work_heap = Heap::PQ::new('min', sub {$a->[2] <=> $b->[2]});

	$work_heap->push([0,0,0,'E',1]); # x,y,loss,dir,run
	my %closed;
	my %grid;
	while (my $job = $work_heap->pop()) {
		my ($x,$y,$loss,$dir,$run) = @{$job};
		my $closed_key = "$x,$y,$dir,$run";
		next if exists $closed{$closed_key};
		$closed{$closed_key} = 1;

		if ($x == $dest_x && $y == $dest_y) {
			$best = $loss;
			last;
		}

		if ($run < $max_run) {
			my $new_job = eval_dir($dir, $city, \%grid, $run, $job);
			$work_heap->push($new_job) if defined $new_job;
		}

		if ($run >= $min_run) {
			for my $rot ('CW','CCW') {
				my $new_dir = Position->turn_str($rot, $dir);
				my $new_job = eval_dir($new_dir, $city, \%grid, 0, $job);
				$work_heap->push($new_job) if defined $new_job;
			}
		}
	}

	return $best;
}

sub eval_dir($dir, $city, $grid, $run, $job) {
	my ($jx, $jy, $loss) = @{$job};
	my @offset = xy_offset($dir);
	my $off_x = $jx + $offset[0];
	my $off_y = $jy + $offset[1];

	my $new_job;
	return $new_job unless ($off_x >= 0 && $off_x <= $city->x_max()
						 && $off_y >= 0 && $off_y <= $city->y_max());

	my $loss_at_offset = $loss + $city->get_xy($off_x, $off_y);
	my $key = "$off_x,$off_y,$dir," . ($run + 1);

	return $new_job if exists $grid->{$key} && $grid->{$key} <= $loss_at_offset;
	$grid->{$key} = $loss_at_offset;

	$new_job = [$off_x, $off_y, $loss_at_offset, $dir, $run+1];
	return $new_job;
}
