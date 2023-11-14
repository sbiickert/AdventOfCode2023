use Modern::Perl 2023;

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory;

package AOC::Geometry;
use Exporter;
use feature 'signatures';
use List::Util qw(min max first);
#use Data::Dumper;
#use Storable 'dclone';

our @ISA = qw( Exporter );
#our @EXPORT_OK = qw(c2_make c3_make);
our @EXPORT = qw(
	c2_make c2_offset c2_to_str c2_from_str c2_origin
	c2_equal c2_add c2_delta c2_distance c2_manhattan

	p2_make p2_equal p2_to_str
	p2_location p2_direction p2_offset
	p2_move_forward p2_turn

	c3_make c3_to_str c3_from_str
	c3_equal c3_add c3_delta c3_distance c3_manhattan

	e1_make e1_contains e1_equal e1_intersect e1_is_empty
	e1_overlaps e1_to_str e1_union e1_size e1_contains_value

	e2_make e2_build e2_expanded_to_fit e2_to_str e2_is_empty
	e2_min e2_max e2_width e2_height e2_area e2_all_coords
	e2_equal e2_contains e2_intersect e2_union e2_inset

	e3_make e3_build e3_expand_to_fit e3_to_str
	e3_min e3_max e3_width e3_height e3_depth
	e3_volume e3_all_coords e3_equal e3_contains
);

# -------------------------------------------------------
# Coord2D
#
# Data model: array reference [x,y]
# -------------------------------------------------------
sub c2_make($x, $y) {
	return [$x, $y];
}

our %OFFSET_DIRS = ('N' 	=> c2_make( 0,-1),
					'NE' 	=> c2_make( 1,-1),
					'E' 	=> c2_make( 1, 0),
					'SE' 	=> c2_make( 1, 1),
					'S' 	=> c2_make( 0, 1),
					'SW' 	=> c2_make(-1, 1),
					'W' 	=> c2_make(-1, 0),
					'NW' 	=> c2_make(-1,-1));

our %OFFSET_ALIASES = ('UP'	=> 'N', 'RIGHT' => 'E', 'DOWN' 	=> 'S', 'LEFT' 	=> 'W',
						'^' => 'N', '>' => 'E', 'v' => 'S', '<' => 'W');

sub c2_offset($dir_str) {
	my $result;
	my $resolved = c2_resolve_offset_alias($dir_str);
	if (exists $OFFSET_DIRS{$resolved}) {
		my $off = $OFFSET_DIRS{$resolved};
		$result = c2_make($off->[0], $off->[1]);
	}
	else {
		$result = c2_origin();
	}
	return $result;
}

# Not exported
sub c2_resolve_offset_alias($dir_str) {
	my $result = $dir_str;
	$result = $OFFSET_ALIASES{$dir_str} if exists $OFFSET_ALIASES{$dir_str};
	return $result;
}

sub c2_to_str($c2d) {
	return '[' . $c2d->[0] . ',' . $c2d->[1] . ']';
}

sub c2_from_str($val) {
	if ($val =~ m/\[(-?\d+),(-?\d+)\]/) {
		return c2_make($1, $2);
	}
	return 0;
}

sub c2_origin() {
	return c2_make(0,0);
}

sub c2_equal($c1, $c2) {
	return $c1->[0] == $c2->[0] && $c1->[1] == $c2->[1];
}

sub c2_add($c1, $c2) {
	return c2_make($c2->[0] + $c1->[0], $c2->[1] + $c1->[1]);
}

sub c2_delta($c1, $c2) {
	return c2_make($c2->[0] - $c1->[0], $c2->[1] - $c1->[1]);
}

sub c2_distance($c1, $c2) {
	my $delta = c2_delta($c1, $c2);
	return sqrt($delta->[0]**2 + $delta->[1]**2);
}

sub c2_manhattan($c1, $c2) {
	my $delta = c2_delta($c1, $c2);
	return abs($delta->[0]) + abs($delta->[1]);
}


# -------------------------------------------------------
# Position2D
#
# Data model: array reference [x,y,direction]
# -------------------------------------------------------

sub p2_make($c2d, $dir_str = 'N') {
	return [$c2d->[0], $c2d->[1], c2_resolve_offset_alias($dir_str)];
}

sub p2_equal($p1, $p2) {
	return c2_equal( p2_location($p1), p2_location($p2) ) && (p2_direction($p1) eq p2_direction($p2));
}

sub p2_to_str($p2d) {
	return '{' . c2_to_str(p2_location($p2d)) . ' ' . p2_direction($p2d) . '}';
}

sub p2_location($p2d) {
	return c2_make($p2d->[0], $p2d->[1]);
}

sub p2_direction($p2d) {
	return $p2d->[2];
}

sub p2_offset($p2d) {
	return c2_offset( p2_direction( $p2d ) );
}

sub p2_turn($p2d, $rot_str) {
	my $step = 0;
	if ( first { $_ eq $rot_str } ('CW', 'RIGHT', 'R')) { $step = 1; }
	if ( first { $_ eq $rot_str } ('CCW', 'LEFT', 'L')) { $step = -1; }
	my @ordered = ('N', 'E', 'S', 'W');
	my $current_dir = p2_direction($p2d);
	my $index = first { $ordered[$_] eq $current_dir } 0..$#ordered;
	if ($index < 0) {
		# Direction isn't one of NESW
		return p2_make(p2_location($p2d), $current_dir);
	}
	$index = ($index + $step) % 4;
	return p2_make(p2_location($p2d), $ordered[$index]);
}

sub p2_move_forward($p2d, $distance = 1) {
	my $new_loc = p2_location($p2d);
	my $off = p2_offset($p2d);
	for (0..$distance-1) {
		$new_loc = c2_add( $new_loc, $off );
	}
	return p2_make( $new_loc, p2_direction($p2d) );
}

# -------------------------------------------------------
# Coord3D
#
# Data model: array reference [x,y,z]
# -------------------------------------------------------
sub c3_make($x, $y, $z) {
	return [$x, $y, $z];
}

sub c3_to_str($c2d) {
	return '[' . $c2d->[0] . ',' . $c2d->[1] . ',' . $c2d->[2] . ']';
}

sub c3_from_str($val) {
	if ($val =~ m/\[(-?\d+),(-?\d+),(-?\d+)\]/) {
		return c3_make($1, $2, $3);
	}
	return 0;
}

sub c3_equal($c1, $c2) {
	return $c1->[0] == $c2->[0] &&
			$c1->[1] == $c2->[1] &&
			$c1->[2] == $c2->[2];
}

sub c3_add($c1, $c2) {
	return c3_make($c2->[0] + $c1->[0],
					  $c2->[1] + $c1->[1],
					  $c2->[2] + $c1->[2]);
}

sub c3_delta($c1, $c2) {
	return c3_make($c2->[0] - $c1->[0],
					  $c2->[1] - $c1->[1],
					  $c2->[2] - $c1->[2]);
}

sub c3_distance($c1, $c2) {
	my $delta = c3_delta($c1, $c2);
	return sqrt($delta->[0]**2 + $delta->[1]**2 + $delta->[2]**2);
}

sub c3_manhattan($c1, $c2) {
	my $delta = c3_delta($c1, $c2);
	return abs($delta->[0]) + abs($delta->[1]) + abs($delta->[2]);
}


# -------------------------------------------------------
# Extent1D (i.e. a range)
#
# Data model: array reference [min,max]
# -------------------------------------------------------
sub e1_make($i1, $i2) {
	return [min($i1, $i2), max($i1, $i2)];
}

sub e1_equal($e1, $e2) {
	if (e1_is_empty($e1) && e1_is_empty($e2)) { return 1; }
	if (e1_is_empty($e1) || e1_is_empty($e2)) { return 0; }
	return ($e1->[0] == $e2->[0] && $e2->[1] == $e1->[1]);
}

sub e1_size($e1d) {
	if (e1_is_empty($e1d)) { return 0; }
	return $e1d->[1] - $e1d->[0] + 1;
}

sub e1_contains($e1, $e2) {
	if (e1_is_empty($e1) || e1_is_empty($e2)) { return 0; }
	return ($e1->[0] <= $e2->[0] && $e2->[1] <= $e1->[1]);
}

sub e1_contains_value($e1, $v) {
	if (e1_is_empty($e1)) { return 0; }
	return ($e1->[0] <= $v && $v <= $e1->[1]);
}

sub e1_overlaps($e1, $e2) {
	my $intersect = e1_intersect($e1, $e2);
	return 0 if e1_is_empty($intersect);
	return 1;
}

sub e1_union($e1, $e2) {
	if (e1_is_empty($e1) || e1_is_empty($e2)) { return []; }
	my $min = min($e1->[0], $e2->[0]);
	my $max = max($e1->[1], $e2->[1]);
	return [$min, $max];
}

sub e1_intersect($e1, $e2) {
	if (e1_is_empty($e1) || e1_is_empty($e2)) { return []; }
	my $bigmin = max($e1->[0], $e2->[0]);
	my $smallmax = min($e1->[1], $e2->[1]);
	if ($bigmin <= $smallmax) {
		return [$bigmin, $smallmax];
	}
	return []; #empty
}

sub e1_is_empty($e1d) {
	return scalar(@{$e1d}) == 0;
}

sub e1_to_str($e1d) {
	if (e1_is_empty($e1d)) {
		return '{empty}';
	}
	return '{min: ' . $e1d->[0] . ', max: ' . $e1d->[1] . '}';
}


# -------------------------------------------------------
# Extent2D
#
# Data model: array reference [xmin,ymin,xmax,ymax]
# -------------------------------------------------------
sub e2_make($c_min, $c_max) {
	return [$c_min->[0], $c_min->[1], $c_max->[0], $c_max->[1]];
}

sub e2_build(@c_list) {
	my $ext = [];
	for my $c ( @c_list ) {
		$ext = e2_expanded_to_fit($ext, $c);
	}
	return $ext;
}

sub e2_expanded_to_fit($e2d, $c2d) {
	if (e2_is_empty($e2d)) {
		return [$c2d->[0], $c2d->[1], $c2d->[0], $c2d->[1]];
	}
	return [
		min($e2d->[0], $c2d->[0]),
		min($e2d->[1], $c2d->[1]),
		max($e2d->[2], $c2d->[0]),
		max($e2d->[3], $c2d->[1])];
}

sub e2_is_empty($e2d) {
	return scalar(@{$e2d}) == 0;
}

sub e2_to_str($e2d) {
	if (e2_is_empty($e2d)) {
		return '{empty}';
	}
	return '{min: [' . $e2d->[0] . ',' . $e2d->[1] . '], max: [' . $e2d->[2] . ',' . $e2d->[3] . ']}';
}

sub e2_min($e2d) {
	return c2_make($e2d->[0], $e2d->[1]);
}

sub e2_max($e2d) {
	return c2_make($e2d->[2], $e2d->[3]);
}

sub e2_width($e2d) {
	if (e2_is_empty($e2d)) { return 0; }
	return $e2d->[2] - $e2d->[0] + 1;
}

sub e2_height($e2d) {
	if (e2_is_empty($e2d)) { return 0; }
	return $e2d->[3] - $e2d->[1] + 1;
}

sub e2_area($e2d) {
	return e2_width($e2d) * e2_height($e2d);
}

sub e2_all_coords($e2d) {
	my @coords = ();
	if (e2_is_empty($e2d)) { return @coords; }
	for (my $x = $e2d->[0]; $x <= $e2d->[2]; $x++) {
		for (my $y = $e2d->[1]; $y <= $e2d->[3]; $y++) {
			push( @coords, c2_make($x, $y) );
		}
	}
	return @coords;
}

sub e2_equal($e1, $e2) {
	return $e1->[0] == $e2->[0] &&
			$e1->[1] == $e2->[1] &&
			$e1->[2] == $e2->[2] &&
			$e1->[3] == $e2->[3];
}

sub e2_contains($e2d, $c2d) {
	if (e2_is_empty($e2d)) { return 0; }
	return $e2d->[0] <= $c2d->[0] && $c2d->[0] <= $e2d->[2] &&
			$e2d->[1] <= $c2d->[1] && $c2d->[1] <= $e2d->[3];
}

sub e2_intersect($e1, $e2) {
	if (e2_is_empty($e1) || e2_is_empty($e2)) { return []; }
	my $common_min_x = max($e1->[0], $e2->[0]);
	my $common_max_x = min($e1->[2], $e2->[2]);
	if ($common_max_x < $common_min_x) { return []; }
	my $common_min_y = max($e1->[1], $e2->[1]);
	my $common_max_y = min($e1->[3], $e2->[3]);
	if ($common_max_y < $common_min_y) { return []; }

	return [$common_min_x, $common_min_y, $common_max_x, $common_max_y];
}

sub e2_union($e1, $e2) {
	my @results = ();
	if (e2_equal($e1, $e2)) { return ($e1); }

	my $e_int = e2_intersect($e1, $e2);
	if (e2_is_empty($e_int)) {
		if (!e2_is_empty($e1)) { push(@results, $e1); }
		if (!e2_is_empty($e2)) { push(@results, $e2); }
		return @results;
	}

	push( @results, $e_int );
	for my $e ($e1, $e2) {
		if (e2_equal($e, $e_int)) { next; }

		if ($e->[0] < $e_int->[0]) { # xmin
			if ($e->[1] < $e_int->[1]) { # ymin
				push( @results, [$e->[0], $e->[1], $e_int->[0]-1, $e_int->[1]-1] );
			}
			if ($e->[3] > $e_int->[3]) { # ymax
				push( @results, [$e->[0], $e_int->[3]+1, $e_int->[0]-1, $e->[3]] );
			}
			push( @results, [$e->[0], $e_int->[1], $e_int->[0]-1, $e_int->[3]] );
		}
		if ($e_int->[2] < $e->[2]) {
			if ($e->[1] < $e_int->[1]) { # ymin
				push( @results, [$e_int->[2]+1, $e->[1], $e->[2], $e_int->[1]-1] );
			}
			if ($e->[3] > $e_int->[3]) { # ymax
				push( @results, [$e_int->[2]+1, $e_int->[3]+1, $e->[2], $e->[3]] );
			}
			push( @results, [$e_int->[2]+1, $e_int->[1], $e->[2], $e_int->[3]] );
		}
		if ($e->[1] < $e_int->[1]) { #ymin
			push( @results, [$e_int->[0], $e->[1], $e_int->[2], $e_int->[1]-1] );
		}
		if ($e_int->[3] < $e->[3]) { #ymax
			push( @results, [$e_int->[0], $e_int->[3]+1, $e_int->[2], $e->[3]] );
		}
	}
	return @results;
}

sub e2_inset($e2d, $inset) {
	my $result = [];
	$result->[0] = $e2d->[0] + $inset;
	$result->[1] = $e2d->[1] + $inset;
	$result->[2] = $e2d->[2] - $inset;
	$result->[3] = $e2d->[3] - $inset;
	die if $result->[2] <= $result->[0] || $result->[3] <= $result->[1];
	return $result;
}


# -------------------------------------------------------
# Extent3D
#
# Data model: array reference [xmin,ymin,zmin,xmax,ymax,zmax]
# -------------------------------------------------------
sub e3_make($c_min, $c_max) {
	return [$c_min->[0], $c_min->[1], $c_min->[2], $c_max->[0], $c_max->[1], $c_max->[2]];
}

sub e3_build(@c_list) {
	my @data = ();
	for my $c ( @c_list ) {
		e3_expand_to_fit(\@data, $c);
	}
	return \@data;
}

sub e3_expand_to_fit($e3d, $c3d) {
	if (e3_is_empty($e3d)) {
		$e3d->[0] = $c3d->[0];
		$e3d->[1] = $c3d->[1];
		$e3d->[2] = $c3d->[2];
		$e3d->[3] = $c3d->[0];
		$e3d->[4] = $c3d->[1];
		$e3d->[5] = $c3d->[2];
	}
	else {
		$e3d->[0] = min($e3d->[0], $c3d->[0]);
		$e3d->[1] = min($e3d->[1], $c3d->[1]);
		$e3d->[2] = min($e3d->[2], $c3d->[2]);
		$e3d->[3] = max($e3d->[3], $c3d->[0]);
		$e3d->[4] = max($e3d->[4], $c3d->[1]);
		$e3d->[5] = max($e3d->[5], $c3d->[2]);
	}
}

sub e3_is_empty($e3d) {
	return scalar(@{$e3d}) == 0;
}

sub e3_to_str($e3d) {
	if (e3_is_empty($e3d)) {
		return '{empty}';
	}
	return '{min: [' . $e3d->[0] . ',' . $e3d->[1] . ',' . $e3d->[2] . '], max: [' . $e3d->[3] . ',' . $e3d->[4] . ',' . $e3d->[5] . ']}';
}

sub e3_min($e3d) {
	return c3_make($e3d->[0], $e3d->[1], $e3d->[2]);
}

sub e3_max($e3d) {
	return c3_make($e3d->[3], $e3d->[4], $e3d->[5]);
}

sub e3_width($e3d) {
	if (e3_is_empty($e3d)) { return 0; }
	return $e3d->[3] - $e3d->[0] + 1;
}

sub e3_height($e3d) {
	if (e3_is_empty($e3d)) { return 0; }
	return $e3d->[4] - $e3d->[1] + 1;
}

sub e3_depth($e3d) {
	if (e3_is_empty($e3d)) { return 0; }
	return $e3d->[5] - $e3d->[2] + 1;
}

sub e3_volume($e3d) {
	return e3_width($e3d) * e3_height($e3d) * e3_depth($e3d);
}

sub e3_all_coords($e3d) {
	my @coords = ();
	if (e3_is_empty($e3d)) { return @coords; }
	for (my $x = $e3d->[0]; $x <= $e3d->[3]; $x++) {
		for (my $y = $e3d->[1]; $y <= $e3d->[4]; $y++) {
			for (my $z = $e3d->[2]; $z <= $e3d->[5]; $z++) {
				push( @coords, c3_make($x, $y, $z) );
			}
		}
	}
	return @coords;
}

sub e3_equal($e1, $e2) {
	return $e1->[0] == $e2->[0] &&
			$e1->[1] == $e2->[1] &&
			$e1->[2] == $e2->[2] &&
			$e1->[3] == $e2->[3] &&
			$e1->[4] == $e2->[4] &&
			$e1->[5] == $e2->[5];
}

sub e3_contains($e3d, $c3d) {
	if (e3_is_empty($e3d)) { return 0; }
	return $e3d->[0] <= $c3d->[0] && $c3d->[0] <= $e3d->[3] &&
			$e3d->[1] <= $c3d->[1] && $c3d->[1] <= $e3d->[4] &&
			$e3d->[2] <= $c3d->[2] && $c3d->[2] <= $e3d->[5];
}


1;