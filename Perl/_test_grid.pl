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
use AOC::Grid;
use Data::Dumper;

test_grid2d();


sub test_grid2d {
	say "\nTesting Grid2D";
	my $g2d = g2_make('.', 'rook');
	print Dumper($g2d);
	
	my @coords = (c2_make(1,1), c2_make(2,2), c2_make(3,3), c2_make(4,4));
	g2_set($g2d, $coords[0], 'A');
	g2_set($g2d, $coords[1], 'B');
	g2_set($g2d, $coords[3], 'D');
	g2_print($g2d);
	print Dumper($g2d);
	say 'The value at ' . c2_to_str($coords[1]) . ' is ' . g2_get($g2d, $coords[1]);
	say 'The value at ' . c2_to_str($coords[2]) . ' is ' . g2_get($g2d, $coords[2]);
	my @all = g2_coords($g2d);
	say 'All coords in grid:';
	for my $c (@all) { say c2_to_str($c); }
	my @ds = g2_coords_with_value($g2d, 'D');
	say "All D's in grid:";
	for my $c (@ds) { say c2_to_str($c); }
	my @xs = g2_coords_with_value($g2d, 'X');
	say "All X's in grid:";
	for my $c (@xs) { say c2_to_str($c); }
	say 'Histogram of values:';
	print Dumper(g2_histogram( $g2d ));
	my @neighbors = g2_neighbors( $g2d, $coords[1] );
	for my $n (@neighbors) {
		g2_set($g2d, $n, '*');
	}
	g2_print($g2d);
	say 'Histogram of values:';
	print Dumper(g2_histogram( $g2d ));
}