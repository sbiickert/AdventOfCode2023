use Modern::Perl 2024;
use Test::Simple tests => 60;
use Data::Dumper;

use AOC::Util;
use AOC::Geometry;

say "Perl version : ".$];

test_coord2d();
test_pos2d();
test_extent1d();
test_extent2d();
# test_coord3d();
# test_extent3d();

sub test_coord2d {
	say "\nTesting Coord2D";
	my $c2d = c2_make(10, 30);
	my $c_str = $c2d->to_str();
	ok($c_str eq "[10,30]", "c2_to_str worked");

	my $c_from_str = c2_from_str($c_str);
	ok($c_from_str->equals($c2d), "c2_from_str worked");

	my $other = c2_make(10,30);
	ok($other->equals($c2d), "Equal coords are equal.");

	$other = c2_make(5,20);
	ok(!$c2d->equals($other), "Unequal coords are unequal.");

	ok(c2_make(0,0)->equals( c2_origin() ), 'Origin check');

	my $delta = $c2d->delta($other);
	ok($delta->col == -5 && $delta->row == -10, "Delta was correct.");

	ok(approx_equal($c2d->distance($other), 11.1803398874989), "Distance was within tolerance.");
	ok($c2d->manhattan($other) == 15, "Manhattan distance was correct.");

	my $origin = c2_origin();
	ok( $origin->offset('N')->equals(c2_make( 0,-1)), "Tested offset N");
	ok( $origin->offset('<')->equals(c2_make(-1, 0)), "Tested offset <");
	ok( $origin->offset('?')->equals(c2_make( 0, 0)), "Tested offset ?");

	$other = c2_make(1,1);
	ok( !$origin->is_adjacent( $other ), "Tested diagonal coord not adjacent for ROOK rule.");
	ok( $origin->is_adjacent( $other, BISHOP() ), "Tested diagonal coord is adjacent for BISHOP rule.");
	my @adj_coords = $origin->get_adjacent_coords();
	ok( scalar(@adj_coords) == 4, "4 adjacent coords for ROOK.");
}

sub test_pos2d {
	say "\nTesting Pos2D";
	my $p2d = p2_make( c2_origin() );
	ok($p2d->coord()->equals( c2_origin() ), 'Tested make - location');
	ok($p2d->dir() eq 'N', 'Tested make - default direction');

	$p2d = p2_make( c2_make(5,5), '<' );
	ok($p2d->dir() eq 'W', 'Tested make direction <');
	$p2d = $p2d->turn( 'CW' );
	ok($p2d->dir() eq 'N', 'Tested turning CW once.');
	$p2d = $p2d->turn( 'CCW' );
	ok($p2d->dir() eq 'W', 'Tested turning CCW once.');
	for (0..5) {
		$p2d = $p2d->turn( 'CCW' );
	}
	ok($p2d->dir() eq 'E', 'Tested turning CCW six times.');

	$p2d = $p2d->move_forward();
	ok($p2d->coord()->equals( c2_make(6,5) ), 'Tested moving forward once');
	$p2d = $p2d->move_forward(4);
	ok($p2d->coord()->equals( c2_make(10,5) ), 'Tested moving forward 4');

	my $bad = p2_make( c2_origin(), '?' );
	my $moved = $bad->move_forward();
	ok($bad->equals($moved), "Tested moving with a bad direction.");

	# Need to test clone
}

sub test_extent1d {
	say "\nTesting Extent1D";
	my @exts = (
		e1_make(0, 10),
		e1_make(4, 2),
		e1_make(4, 10),
		e1_make(5, 8));
	push(@exts, (
		$exts[1]->intersect($exts[3]),
		$exts[1]->intersect($exts[2]),
		$exts[1]->union($exts[3]),
		e1_make(0, 10)));
	my @strs = map {$_ ? $_->to_str() : "empty"} @exts;

	ok($exts[0]->size() == 11, "$strs[0] was the expected size.");
	ok($exts[1]->min() == 2 && $exts[1]->max() == 4, "$strs[1] limits were correct.");

	ok($exts[0]->contains($exts[1]), "$strs[0] contains $strs[1]");
	ok(!$exts[1]->contains($exts[0]), "$strs[1] does not contain $strs[0]");
	ok($exts[0]->overlaps($exts[1]), "$strs[0] overlaps $strs[1]");
	ok($exts[1]->overlaps($exts[2]), "$strs[1] overlaps $strs[2]");
	ok($exts[0]->contains($exts[2]), "$strs[0] contains $strs[2]");
	ok(!$exts[1]->overlaps($exts[3]), "$strs[1] does not overlap $strs[3]");

	ok(!e1_is_valid($exts[4]), "$strs[4] is not a valid extent");
	ok($exts[5]->size() == 1, "$strs[5] is the right size");
	ok($exts[6]->size() == 7, "$strs[6] is the right size");
	ok($exts[0]->equals($exts[7]), "$strs[0] and $strs[7] are equal");
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
		e2_make( @c_list ));
	push(@e,
		$e[1]->expanded($c[3]),
		e2_from_ints(1,1,10,10)->intersect(e2_from_ints(5,5,12,12)),
		e2_from_ints(1,1,10,10)->intersect(e2_from_ints(5,5,7,7)),
		e2_from_ints(1,1,10,10)->intersect(e2_from_ints(1,1,12,2)),
		e2_from_ints(1,1,10,10)->intersect(e2_from_ints(11,11,12,12)),
		e2_from_ints(1,1,10,10)->intersect(e2_from_ints(1,10,10,20)));

	ok($e[0]->nw()->X() == -1 && $e[0]->nw()->Y() == 1 &&
		$e[0]->se()->X() == 2 && $e[0]->se()->Y() == 8,
		$e[0]->to_str() . " had the expected values.");
	ok($e[1]->nw()->X() == -1 && $e[1]->nw()->Y() == 1 &&
		$e[1]->se()->X() == 3 && $e[1]->se()->Y() == 8,
		$e[1]->to_str() . " had the expected values.");
	ok($e[2]->nw()->X() == -1 && $e[2]->nw()->Y() == 1 &&
		$e[2]->se()->X() == 4 && $e[2]->se()->Y() == 8,
		 $e[2]->to_str() . " had the expected values.");

	# e2_min e2_max e2_width e2_height e2_area
	ok($e[2]->nw()->equals(c2_make(-1,1)), $e[2]->to_str() . " min was correct.");
	ok($e[2]->se()->equals(c2_make( 4,8)), $e[2]->to_str() . " max was correct.");
	ok($e[1]->width() == 5, $e[1]->to_str() . " width was correct.");
	ok($e[1]->height() == 8, $e[1]->to_str() . " height was correct.");
	ok($e[1]->area() == 40, $e[1]->to_str() . " area was correct.");

	# e2_equal
	my $e_clone = $e[2]->clone();
	ok($e[2]->equals($e_clone), $e[2]->to_str()." was equal to clone ". $e_clone->to_str());
	ok($e[2]->equals(e2_from_ints(-1,1,4,8)), $e[2]->to_str()." was equal to -1,1,4,8");

	# e2_contains
	ok($e[1]->contains($c[1]), $e[1]->to_str() . " contains " . $c[1]->to_str());
	ok($e[2]->contains($c[3]), $e[2]->to_str() . " contains " . $c[3]->to_str());

	# e2_inset
	ok($e[0]->inset(1)->equals(e2_from_ints(0,2,1,7)), "Inset extent by 1");
	ok(!e2_is_valid($e[0]->inset(2)), "Inset to negative width is empty.");

	# e2_intersect
	ok($e[3]->equals(e2_from_ints(5,5,10,10)), "Intersect result was correct");
	ok($e[4]->equals(e2_from_ints(5,5,7,7)), "Intersect result was correct");
	ok($e[5]->equals(e2_from_ints(1,1,10,2)), "Intersect result was correct");
	ok(!e2_is_valid($e[6]), "Intersect result was empty");
	ok($e[7]->equals(e2_from_ints(1,10,10,10)), "Intersect result was correct");

	# e2_union
	my @products = e2_from_ints(1,1,10,10)->union(e2_from_ints(5,5,12,12));
	my $expected = [e2_from_ints(5,5,10,10),e2_from_ints(1,1,4,4),e2_from_ints(1,5,4,10),e2_from_ints(5,1,10,4),e2_from_ints(11,11,12,12),e2_from_ints(11,5,12,10),e2_from_ints(5,11,10,12)];
	ok(_test_extent_union(\@products, $expected), "Union result was correct.");
	@products = e2_from_ints(1,1,10,10)->union(e2_from_ints(5,5,7,7));
	$expected = [e2_from_ints(5,5,7,7),e2_from_ints(1,1,4,4),e2_from_ints(1,8,4,10),e2_from_ints(1,5,4,7),e2_from_ints(8,1,10,4),e2_from_ints(8,8,10,10),e2_from_ints(8,5,10,7),e2_from_ints(5,1,7,4),e2_from_ints(5,8,7,10)];
	ok(_test_extent_union(\@products, $expected), "Union result was correct.");
	@products = e2_from_ints(1,1,10,10)->union(e2_from_ints(1,1,12,2));
	$expected = [e2_from_ints(1,1,10,2),e2_from_ints(1,3,10,10),e2_from_ints(11,1,12,2)];
	ok(_test_extent_union(\@products, $expected), "Union result was correct.");
	@products = e2_from_ints(1,1,10,10)->union(e2_from_ints(11,11,12,12));
	$expected = [e2_from_ints(1,1,10,10),e2_from_ints(11,11,12,12)];
	ok(_test_extent_union(\@products, $expected), "Union result was correct.");
	@products = e2_from_ints(1,1,10,10)->union(e2_from_ints(1,10,10,20));
	$expected = [e2_from_ints(1,10,10,10),e2_from_ints(1,1,10,9),e2_from_ints(1,11,10,20)];
	ok(_test_extent_union(\@products, $expected), "Union result was correct.");

	# e2_all_coords
	my @all_coords = $e[1]->all_coords();
# 	print(Dumper(map {$_->to_str()} @all_coords));
	ok(scalar(@all_coords) == $e[1]->area(), "Number of coordinates is equal to the area.");
}

sub _test_extent_union {
	my @actual = @{shift(@_)};
	my @expected = @{shift(@_)};

# 	my @strs = map {$_ ? $_->to_str() : $_} @actual;
# 	say "Actual: " . join(",", @strs);
# 	@strs = map {$_ ? $_->to_str() : $_} @expected;
# 	say "Expected: " . join(",", @strs);

	if (scalar(@actual) != scalar(@expected)) {
		say "Number of resultants (".scalar(@actual).") does not match expected (".scalar(@expected).")";
		return 0;
	}

	for (my $i = 0; $i <= $#actual; $i++) {
		if (!$actual[$i]->equals($expected[$i])) { return 0; }
	}
	return 1;
}

sub test_coord3d {
	say "test_coord3d not implemented.";
# 	say "\nTesting Coord3D";
# 	my $c3d = c3_make(10, 30, -5);
# 	my $c_str = c3_to_str($c3d);
# 	ok($c_str eq "[10,30,-5]", "c3_to_str worked");
#
# 	my $c_from_str = c3_from_str($c_str);
# 	ok(c3_equal($c3d, $c_from_str), "c3_from_str worked");
#
# 	my $other = c3_make(10,30,-5);
# 	ok(c3_equal($c3d, $other), "Equal coords are equal.");
#
# 	$other = c3_make(5,20,15);
# 	ok(!c3_equal($c3d, $other), "Unequal coords are unequal.");
#
# 	my $delta = c3_delta($c3d, $other);
# 	ok($delta->[0] == -5 && $delta->[1] == -10 && $delta->[2] == 20, "Delta was correct.");
#
# 	ok(approx_equal(c3_distance($c3d, $other), 22.9128784747792), "Distance was within tolerance.");
# 	ok(c3_manhattan($c3d, $other) == 35, "Manhattan distance was correct.");
}

sub test_extent3d {
	say "test_extent3d not implemented.";
}
