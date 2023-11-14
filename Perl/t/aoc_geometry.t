use Modern::Perl 2023;
use Test::Simple tests => 62;
use Data::Dumper;

use AOC::Util;
use AOC::Geometry;

say "Perl version : ".$];

test_coord2d();
test_coord3d();
test_extent1d();
test_extent2d();
test_extent3d();
test_pos2d();

sub test_coord2d {
	say "\nTesting Coord2D";
	my $c2d = c2_make(10, 30);
	my $c_str = c2_to_str($c2d);
	ok($c_str eq "[10,30]", "c2_to_str worked");

	my $c_from_str = c2_from_str($c_str);
	ok(c2_equal($c2d, $c_from_str), "c2_from_str worked");

	my $other = c2_make(10,30);
	ok(c2_equal($c2d, $other), "Equal coords are equal.");

	$other = c2_make(5,20);
	ok(!c2_equal($c2d, $other), "Unequal coords are unequal.");

	ok(c2_equal( c2_make(0,0), c2_origin() ), 'Origin check');

	my $delta = c2_delta($c2d, $other);
	ok($delta->[0] == -5 && $delta->[1] == -10, "Delta was correct.");

	ok(approx_equal(c2_distance($c2d, $other), 11.1803398874989), "Distance was within tolerance.");
	ok(c2_manhattan($c2d, $other) == 15, "Manhattan distance was correct.");

	ok( c2_equal(c2_offset('N'), c2_make(0,-1)), "Tested offset N");
	ok( c2_equal(c2_offset('<'), c2_make(-1,0)), "Tested offset <");
	ok( c2_equal(c2_offset('?'), c2_make(0,0)), "Tested offset ?");
}

sub test_pos2d {
	say "\nTesting Pos2D";
	my $p2d = p2_make( c2_origin() );
	say p2_to_str($p2d);
	ok(c2_equal( p2_location($p2d), c2_origin() ), 'Tested make - location');
	ok(p2_direction($p2d) eq 'N', 'Tested make - default direction');
	ok(c2_equal(p2_offset($p2d), c2_offset('N')), 'Tested make - default offset');

	$p2d = p2_make( c2_make(5,5), '<' );
	ok(p2_direction($p2d) eq 'W', 'Tested make direction <');
	$p2d = p2_turn( $p2d, 'CW' );
	ok(p2_direction($p2d) eq 'N', 'Tested turning CW once.');
	$p2d = p2_turn( $p2d, 'CCW' );
	ok(p2_direction($p2d) eq 'W', 'Tested turning CCW once.');
	for (0..5) {
		$p2d = p2_turn( $p2d, 'CCW' );
	}
	ok(p2_direction($p2d) eq 'E', 'Tested turning CCW six times.');

	$p2d = p2_move_forward($p2d);
	ok(c2_equal( p2_location($p2d), c2_make(6,5) ), 'Tested moving forward once');
	$p2d = p2_move_forward($p2d, 4);
	ok(c2_equal( p2_location($p2d), c2_make(10,5) ), 'Tested moving forward 4');

	my $bad = p2_make( c2_origin(), '?' );
	my $moved = p2_move_forward( $bad );
	ok(p2_equal($bad, $moved), "Tested moving with a bad direction.");
}

sub test_coord3d {
	say "\nTesting Coord3D";
	my $c3d = c3_make(10, 30, -5);
	my $c_str = c3_to_str($c3d);
	ok($c_str eq "[10,30,-5]", "c3_to_str worked");

	my $c_from_str = c3_from_str($c_str);
	ok(c3_equal($c3d, $c_from_str), "c3_from_str worked");

	my $other = c3_make(10,30,-5);
	ok(c3_equal($c3d, $other), "Equal coords are equal.");

	$other = c3_make(5,20,15);
	ok(!c3_equal($c3d, $other), "Unequal coords are unequal.");

	my $delta = c3_delta($c3d, $other);
	ok($delta->[0] == -5 && $delta->[1] == -10 && $delta->[2] == 20, "Delta was correct.");

	ok(approx_equal(c3_distance($c3d, $other), 22.9128784747792), "Distance was within tolerance.");
	ok(c3_manhattan($c3d, $other) == 35, "Manhattan distance was correct.");
}

sub test_extent1d {
	say "\nTesting Extent1D";
	my @exts = (
		e1_make(0, 10),
		e1_make(4, 2),
		e1_make(4, 10),
		e1_make(5, 8));
	push(@exts, (
		e1_intersect($exts[1], $exts[3]),
		e1_intersect($exts[1], $exts[2]),
		e1_union($exts[1], $exts[3]),
		e1_make(0, 10)));
	my @strs = map {e1_to_str($_)} @exts;

	ok(e1_size($exts[0]) == 11, "$strs[0] was the expected size.");
	ok($exts[1]->[0] == 2 && $exts[1]->[1] == 4, "$strs[1] limits were correct.");

	ok(e1_contains($exts[0], $exts[1]), "$strs[0] contains $strs[1]");
	ok(!e1_contains($exts[1], $exts[0]), "$strs[1] does not contain $strs[0]");
	ok(e1_overlaps($exts[0], $exts[1]), "$strs[0] overlaps $strs[1]");
	ok(e1_overlaps($exts[1], $exts[2]), "$strs[0] overlaps $strs[2]");
	ok(e1_contains($exts[0], $exts[2]), "$strs[0] contains $strs[2]");
	ok(!e1_overlaps($exts[1], $exts[3]), "$strs[1] does not overlap $strs[3]");

	ok(e1_is_empty($exts[4]), "$strs[4] is empty");
	ok(e1_size($exts[5]) == 1, "$strs[5] is the right size");
	ok(e1_size($exts[6]) == 7, "$strs[6] is the right size");
	ok(e1_equal($exts[0], $exts[7]), "$strs[0] and $strs[7] are equal");
}

sub test_extent2d {
	say "\nTesting Extent2D";

	my @c = (
		c2_make(-1,1),
		c2_make(2,8),
		c2_make(3,3),
		c2_make(4,4));
	my @c_list = ( $c[2], $c[1], $c[0] );

	# e2_make e2_build e2_expanded_to_fit
	my @e = (
		e2_make($c[0], $c[1]),
		e2_build( @c_list ));
	push(@e,
		e2_expanded_to_fit($e[1], $c[3]),
		e2_intersect([1,1,10,10],[5,5,12,12]),
		e2_intersect([1,1,10,10],[5,5,7,7]),
		e2_intersect([1,1,10,10],[1,1,12,2]),
		e2_intersect([1,1,10,10],[11,11,12,12]),
		e2_intersect([1,1,10,10],[1,10,10,20]));

	ok($e[0][0] == -1 && $e[0][1] == 1 && $e[0][2] == 2 && $e[0][3] == 8, e2_to_str($e[0]) . "had the expected values.");
	ok($e[1][0] == -1 && $e[1][1] == 1 && $e[1][2] == 3 && $e[1][3] == 8, e2_to_str($e[1]) . "had the expected values.");
	ok($e[2][0] == -1 && $e[2][1] == 1 && $e[2][2] == 4 && $e[2][3] == 8, e2_to_str($e[2]) . "had the expected values.");

	# e2_min e2_max e2_width e2_height e2_area
	ok(c2_equal(e2_min($e[2]), c2_make(-1,1)), e2_to_str($e[2]) . " min was correct.");
	ok(c2_equal(e2_max($e[2]), c2_make( 4,8)), e2_to_str($e[2]) . " max was correct.");
	ok(e2_width($e[1]) == 5, e2_to_str($e[1]) . " width was correct.");
	ok(e2_height($e[1]) == 8, e2_to_str($e[1]) . " height was correct.");
	ok(e2_area($e[1]) == 40, e2_to_str($e[1]) . " area was correct.");

	# e2_equal e2_contains e2_inset
	ok(e2_equal($e[2], [-1,1,4,8]), "equality was correct.");
	ok(e2_contains($e[1], $c[1]), e2_to_str($e[1]) . " contains " . c2_to_str($c[1]));
	ok(e2_contains($e[2], $c[3]), e2_to_str($e[2]) . " contains " . c2_to_str($c[3]));

	# e2_intersect
	ok(e2_equal($e[3], [5,5,10,10]), "Intersect result was correct");
	ok(e2_equal($e[4], [5,5,7,7]), "Intersect result was correct");
	ok(e2_equal($e[5], [1,1,10,2]), "Intersect result was correct");
	ok(e2_is_empty($e[6]), "Intersect result was empty");
	ok(e2_equal($e[7], [1,10,10,10]), "Intersect result was correct");

	# e2_union
	my @products = e2_union([1,1,10,10],[5,5,12,12]);
	my $expected = [[5,5,10,10],[1,1,4,4],[1,5,4,10],[5,1,10,4],[11,11,12,12],[11,5,12,10],[5,11,10,12]];
	ok(_test_extent_union(\@products, $expected), "Union result was correct.");
	@products = e2_union([1,1,10,10],[5,5,7,7]);
	$expected = [[5,5,7,7],[1,1,4,4],[1,8,4,10],[1,5,4,7],[8,1,10,4],[8,8,10,10],[8,5,10,7],[5,1,7,4],[5,8,7,10]];
	ok(_test_extent_union(\@products, $expected), "Union result was correct.");
	@products = e2_union([1,1,10,10],[1,1,12,2]);
	$expected = [[1,1,10,2],[1,3,10,10],[11,1,12,2]];
	ok(_test_extent_union(\@products, $expected), "Union result was correct.");
	@products = e2_union([1,1,10,10],[11,11,12,12]);
	$expected = [[1,1,10,10],[11,11,12,12]];
	ok(_test_extent_union(\@products, $expected), "Union result was correct.");
	@products = e2_union([1,1,10,10],[1,10,10,20]);
	$expected = [[1,10,10,10],[1,1,10,9],[1,11,10,20]];
	ok(_test_extent_union(\@products, $expected), "Union result was correct.");

	# e2_all_coords
	my @all_coords = e2_all_coords($e[1]);
	ok(scalar(@all_coords) == e2_area($e[1]), "Number of coordinates is equal to the area.");
}

sub _test_extent_union {
	my @actual = @{shift(@_)};
	my @expected = @{shift(@_)};
	if (scalar(@actual) != scalar(@expected)) { return 0; }

	for (my $i = 0; $i <= $#actual; $i++) {
		if (!e2_equal($actual[$i], $expected[$i])) { return 0; }
	}
	return 1;
}

sub test_extent3d {
	say "test_extent3d not implemented.";
}
