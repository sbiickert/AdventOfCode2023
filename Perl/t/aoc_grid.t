use Modern::Perl 2023;
use Test::Simple tests => 25;

use AOC::Geometry;
use AOC::Grid;
use Data::Dumper;

say "Perl version : ".$];

test_grid2d();
test_grid3d();

sub test_grid2d {
	say "\nTesting Grid2D";
	# g2_make g2_get_default g2_get_rule
	my $g2d = g2_make('.', 'rook');
	ok(g2_get_default($g2d) eq '.', "Getting default");
	ok(g2_get_rule($g2d) eq 'rook', "Getting rule");
	ok(e2_is_empty(g2_extent($g2d)), 'Check initial extent is empty');

	my @coords = (c2_make(1,1), c2_make(2,2), c2_make(3,3),
	 c2_make(4,4), c2_make(1,4), c2_make(2,4), c2_make(3,4));

	# g2_set
	g2_set($g2d, $coords[0], 'A');
	g2_set($g2d, $coords[1], 'B');
	g2_set($g2d, $coords[3], 'D');

	my $elf = {"glyph" => "E", "type" => "Elf", "HP" => 100};
	my $gob = {"glyph" => "G", "type" => "Goblin", "HP" => 95};
	my $san = ["S", "Santa", 100];
	g2_set($g2d, $coords[4], $elf);
	g2_set($g2d, $coords[5], $gob);
	g2_set($g2d, $coords[6], $san);

	# g2_get
	ok(g2_get($g2d, $coords[0]) eq 'A', "Testing g2_get");
	ok(g2_get($g2d, $coords[1]) eq 'B', "Testing g2_get");
	ok(g2_get($g2d, $coords[2]) eq g2_get_default($g2d), "Testing g2_get");
	ok(g2_get($g2d, $coords[3]) eq 'D', "Testing g2_get");

	# g2_get_scalar
	ok(g2_get_scalar($g2d, $coords[4]) eq 'E', "Testing g2_get_scalar");
	ok(g2_get_scalar($g2d, $coords[5]) eq 'G', "Testing g2_get_scalar");
	ok(g2_get_scalar($g2d, $coords[6]) eq 'S', "Testing g2_get_scalar");

	# g2_extent
	my $e = g2_extent($g2d);
	ok(c2_equal(e2_min($e), c2_make(1,1)), 'Testing extent min');
	ok(c2_equal(e2_max($e), c2_make(4,4)), 'Testing extent max');

	# g2_coords g2_coords_with_value
	my @all = g2_coords($g2d);
	ok(scalar(@all) == 6, 'Checking returned coords count');
	my @matching = g2_coords_with_value($g2d, 'B');
	ok(scalar(@matching) == 1, 'Checking returned coords count');
	ok(c2_equal($matching[0], $coords[1]), 'Checking returned coord');

	# g2_histogram
	g2_set($g2d, $coords[2], 'B');
	my $hist = g2_histogram($g2d);
	#print Dumper($hist);
	ok($hist->{'A'} == 1 && $hist->{'B'} == 2 && $hist->{'.'} == 9, 'Checking histogram');

	# g2_offsets g2_neighbors
	my @offsets = g2_offsets($g2d);
	ok(scalar(@offsets) == 4, 'Checked rook offset count.');
	@offsets = g2_offsets(g2_make('.', 'queen'));
	ok(scalar(@offsets) == 8, 'Checked queen offset count.');

	my @n = g2_neighbors($g2d, $coords[1]);
	print Dumper(@n);
	ok(c2_equal($n[0],[2,1]) && c2_equal($n[1],[3,2]) && c2_equal($n[2],[2,3]) && c2_equal($n[3],[1,2]), 'Checked rook neighbours');

	# g2_to_str g2_print
	g2_print($g2d);
	my $grid_str = g2_to_str($g2d);
	my $expected = "A . . . \n. B . . \n. . B . \nE G S D \n";
	ok($grid_str eq $expected, 'Checking grid to string');

	$grid_str = g2_to_str($g2d, 0, 1); # invert y
	$expected = "E G S D \n. . B . \n. B . . \nA . . . \n";
	ok($grid_str eq $expected, 'Checking inverted grid to string');

	my %markers = (c2_to_str(c2_make(4,1)) => '*');
	$grid_str = g2_to_str($g2d, \%markers);
	$expected = "A . . * \n. B . . \n. . B . \nE G S D \n";
	ok($grid_str eq $expected, 'Checking inverted grid to string');

	# g2_clear
	g2_clear($g2d, $coords[2]);
	ok(g2_get($g2d, $coords[2]) eq '.', 'Checking grid clearing');
	my $e_original = g2_extent($g2d);
	g2_set($g2d, c2_make(100, 100), 'X');
	ok(c2_equal(e2_max(g2_extent($g2d)), c2_make(100,100)), "Extent after expand is big");
	g2_clear($g2d, c2_make(100, 100), 1);
	ok(e2_equal(g2_extent($g2d), $e_original), "Extent after clear is small");
}

sub test_grid3d {
	say "test_grid3d not implemented.";
}