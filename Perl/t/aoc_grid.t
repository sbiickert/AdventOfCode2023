use Modern::Perl 2024;
use Test::Simple tests => 24;

use AOC::Geometry;
use AOC::Grid;
use Data::Dumper;

say "Perl version : ".$];

test_grid2d();
test_grid3d();

sub test_grid2d {
	say "\nTesting Grid2D";
	# g2_make g2_get_default g2_get_rule
	my $g2d = g2_make('.', ROOK());
	ok($g2d->default() eq '.', "Getting default");
	ok($g2d->rule() eq ROOK(), "Getting rule");
	ok(!e2_is_valid($g2d->extent()), 'Check initial extent is empty');

	my @coords = (c2_make(1,1), c2_make(2,2), c2_make(3,3),
	 c2_make(4,4), c2_make(1,4), c2_make(2,4), c2_make(3,4));

	# g2_set
	$g2d->set($coords[0], 'A');
	$g2d->set($coords[1], 'B');
	$g2d->set($coords[3], 'D');

	my $elf = {"glyph" => "E", "type" => "Elf", "HP" => 100};
	my $gob = {"glyph" => "G", "type" => "Goblin", "HP" => 95};
	my $san = ["S", "Santa", 100];
	$g2d->set($coords[4], $elf);
	$g2d->set($coords[5], $gob);
	$g2d->set($coords[6], $san);

	# g2_get
	ok($g2d->get($coords[0]) eq 'A', "Testing g2_get");
	ok($g2d->get($coords[1]) eq 'B', "Testing g2_get");
	ok($g2d->get($coords[2]) eq $g2d->default(), "Testing g2_get");
	ok($g2d->get($coords[3]) eq 'D', "Testing g2_get");

	# g2_get_scalar
	ok($g2d->get_scalar($coords[4]) eq 'E', "Testing g2_get_scalar");
	ok($g2d->get_scalar($coords[5]) eq 'G', "Testing g2_get_scalar");
	ok($g2d->get_scalar($coords[6]) eq 'S', "Testing g2_get_scalar");

	# g2_extent
	my $e = $g2d->extent();
	ok($e->nw()->equals(c2_make(1,1)), 'Testing extent min');
	ok($e->se()->equals(c2_make(4,4)), 'Testing extent max');

	# g2_coords g2_coords_with_value
	my @all = $g2d->coords();
	ok(scalar(@all) == 6, 'Checking returned coords count');
	my @matching = $g2d->coords('B');
	ok(scalar(@matching) == 1, 'Checking returned coords count');
	ok($matching[0]->equals($coords[1]), 'Checking returned coord');

	# g2_histogram
	$g2d->set($coords[2], 'B');
	my $hist = $g2d->histogram();
	#print Dumper($hist);
	ok($hist->{'A'} == 1 && $hist->{'B'} == 2 && !exists($hist->{'.'}), 'Checking histogram');
	$hist = $g2d->histogram(1);
	#print Dumper($hist);
	ok($hist->{'A'} == 1 && $hist->{'B'} == 2 && $hist->{'.'} == 9, 'Checking histogram');

	# g2_neighbors
	my @n = $g2d->neighbors($coords[1]);
	#print Dumper(map {$_->to_str()} @n);
	ok($n[0]->equals(c2_make(2,1)) && $n[1]->equals(c2_make(3,2)) &&
		$n[2]->equals(c2_make(2,3)) && $n[3]->equals(c2_make(1,2)), 'Checked rook neighbours');

	# g2_to_str g2_print
	$g2d->print();
	my $grid_str = $g2d->to_str();
	my $expected = "A . . . \n. B . . \n. . B . \nE G S D \n";
	ok($grid_str eq $expected, 'Checking grid to string');

	$grid_str = $g2d->to_str(0, 1); # invert y
	$expected = "E G S D \n. . B . \n. B . . \nA . . . \n";
	ok($grid_str eq $expected, 'Checking inverted grid to string');

	my %markers = (c2_make(4,1)->to_str() => '*');
	$grid_str = $g2d->to_str(\%markers);
	$expected = "A . . * \n. B . . \n. . B . \nE G S D \n";
	ok($grid_str eq $expected, 'Checking inverted grid with markers to string');

	# g2_clear
	$g2d->clear($coords[2]);
	ok($g2d->get($coords[2]) eq '.', 'Checking grid clearing');
	my $e_original = $g2d->extent();
	$g2d->set(c2_make(100, 100), 'X');
	ok($g2d->extent()->se()->equals(c2_make(100,100)), "Extent after expand is big");
	$g2d->clear(c2_make(100, 100), 1);
	ok($g2d->extent()->equals($e_original), "Extent after clear is small");
}

sub test_grid3d {
	say "test_grid3d not implemented.";
}