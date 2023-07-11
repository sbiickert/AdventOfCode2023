#!/usr/bin/env perl

BEGIN {
    use Cwd;
    our $directory = cwd;
    #our $local_lib = $ENV{"HOME"} . '/perl5/lib/perl5';
}

use lib $directory;
#use lib $local_lib;

use Modern::Perl 2022;
use AOC::Util;
use AOC::Geometry;
use Data::Dumper;

test_coord2d();
test_coord3d();
test_extent1d();
test_extent2d();
test_extent3d();

sub test_coord2d {
	say "\nTesting Coord2D";
	my $c2d = c2_make(10, 30);
	say c2_to_str($c2d);
	
	my $other = c2_make(10,30);
	say 'other: ' . c2_to_str($other);
	(c2_equal($c2d, $other)) or die "Coordinates were not equal.";
	
	$other = c2_make(5,20);
	say 'other: ' . c2_to_str($other);
	(!c2_equal($c2d, $other)) or die "Coordinates were equal.";
	
	my $delta = c2_delta($c2d, $other);
	say "Delta from c2d to other is " . c2_to_str($delta);
	($delta->[0] == -5 && $delta->[1] == -10) or die "delta was wrong.";
	
	say "Distance from c2d to other is " . c2_distance($c2d, $other);
	say "Manhattan dist from c2d to other is " . c2_manhattan($c2d, $other);
	(c2_manhattan($c2d, $other) == 15) or die "Manhattan distance was wrong.";
	
	my $clone = c2_from_str( c2_to_str($c2d) );
	say 'The clone ' . c2_to_str($clone) . ' is the same as the original.';
	(c2_equal($c2d, $clone)) or die "The original and the clone are not equal.";
}

sub test_coord3d {
	say "\nTesting Coord3D";
	my $c3d = c3_make(10, 30, -5);
	say c3_to_str($c3d);
	
	my $other = c3_make(10,30,-5);
	say 'other: ' . c3_to_str($other);
	print "Other is equal? " . c3_equal($c3d, $other) . "\n";
	$other = c3_make(5,20,15);
	say 'other: ' . c3_to_str($other);
	print "Other is equal? " . c3_equal($c3d, $other) . "\n";
	
	my $delta = c3_delta($c3d, $other);
	say "Delta from c3d to other is " . c3_to_str($delta);
	say "Distance from c3d to other is " . c3_distance($c3d, $other);
	say "Manhattan dist from c3d to other is " . c3_manhattan($c3d, $other);
	
	my $clone = c3_from_str( c3_to_str($c3d) );
	say 'The clone ' . c3_to_str($clone) . ' is the same as the original.';
}

sub test_extent1d {
	say "\nTesting Extent1D";
	my $e1 = e1_make(0, 10);
	(e1_size($e1) == 11) or die;
	say e1_to_str($e1);
	my $e2 = e1_make(4, 2);
	($e2->[0] == 2) or die;
	($e2->[1] == 4) or die;
	(e1_contains($e1, $e2)) or die;
	(!e1_contains($e2, $e1)) or die;
	(e1_overlaps($e1, $e2)) or die;
	my $e3 = e1_make(4, 10);
	(e1_overlaps($e2, $e3)) or die;
	(e1_contains($e1, $e3)) or die;
	my $e4 = e1_make(5, 8);
	(!e1_overlaps($e2, $e4)) or die;
	my $e5 = e1_intersect($e2, $e4);
	say e1_to_str($e5);
	(e1_is_empty($e5)) or die;
	my $e6 = e1_intersect($e2, $e3);
	say e1_to_str($e6);
	(e1_size($e6) == 1) or die;
	my $e7 = e1_union($e2, $e4);
	say e1_to_str($e7);
	(e1_size($e7) == 7) or die;
	my $e8 = e1_make(0, 10);
	(e1_equal($e1, $e8)) or die;
}

sub test_extent2d {
	say "\nTesting Extent2D";
	my $c1 = c2_make(-1,1);
	my $c2 = c2_make(2,8);
	my $c3 = c2_make(3,3);
	my $c4 = c2_make(4,4);
	my $e1 = e2_make($c1, $c2);
	say e2_to_str($e1);
	($e1->[0] == -1) or die;
	($e1->[1] == 1) or die;
	($e1->[2] == 2) or die;
	($e1->[3] == 8) or die;
	my @c_list = ($c3, $c2, $c1);
	my $e2 = e2_build(@c_list);
	say e2_to_str($e2);
	($e2->[0] == -1) or die;
	($e2->[1] == 1) or die;
	($e2->[2] == 3) or die;
	($e2->[3] == 8) or die;
	say 'The width of e2 is ' . e2_width($e2);
	say 'The height of e2 is ' . e2_height($e2);
	say 'The area of e2 is ' . e2_area($e2);
	(e2_width($e2) == 5) or die;
	(e2_height($e2) == 8) or die;
	(e2_area($e2) == 40) or die;
	say (e2_contains($e2, $c2) ? 'c2 is contained by e2' : 'c2 is outside e2');
	say (e2_contains($e2, $c4) ? 'c4 is contained by e2' : 'c4 is outside e2');
	(e2_contains($e2, $c2)) or die;
	(!e2_contains($e2, $c4)) or die;
	my @all_coords = e2_all_coords($e2);
	(scalar(@all_coords) == e2_area($e2)) or die;
	
	test_e2_intersect([1,1,10,10],[5,5,12,12]);
	test_e2_intersect([1,1,10,10],[5,5,7,7]);
	test_e2_intersect([1,1,10,10],[1,1,12,2]);
	test_e2_intersect([1,1,10,10],[11,11,12,12]);
	test_e2_intersect([1,1,10,10],[1,10,10,20]);
	
	test_e2_union([1,1,10,10],[5,5,12,12]);
	test_e2_union([1,1,10,10],[5,5,7,7]);
	test_e2_union([1,1,10,10],[1,1,12,2]);
	test_e2_union([1,1,10,10],[11,11,12,12]);
	test_e2_union([1,1,10,10],[1,10,10,20]);
}

sub test_e2_intersect {
	my ($e1, $e2) = @_;
	say 'Intersection of ' . e2_to_str($e1) . ' and ' . e2_to_str($e2);
	my $e_int = e2_intersect($e1, $e2);
	say e2_to_str($e_int);
}

sub test_e2_union {
	my ($e1, $e2) = @_;
	say 'Union of ' . e2_to_str($e1) . ' and ' . e2_to_str($e2);
	my @products = e2_union($e1, $e2);
	for my $e (@products) {
		say e2_to_str($e);
	}
}

sub test_extent3d {
	say "test_extent3d not implemented.";
}