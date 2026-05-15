use v5.42;
use feature 'class';
no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory;

package AOC::Geometry;
use Exporter;
# use Data::Printer;
use List::Util 'first';

our @ISA = qw( Exporter );
#our @EXPORT_OK = qw(c2_make c3_make);
our @EXPORT = qw(
	ROOK BISHOP QUEEN
	c2_make c2_from_str c2_origin c2_is_valid
	c3_make c3_from_str c3_origin c3_is_valid
	xy_offset xy_offsets
	d2_from_alias d2_for_rule d2_turn d2_opposite
	p2_make
	e1_make e1_is_valid
	e2_make e2_from_ints e2_is_valid
	e3_make e3_from_ints e3_is_valid
);

our %OFFSET_DIRS = ('N' 	=> Coord2D->new(col => 0, row => -1),
					'NE' 	=> Coord2D->new(col => 1, row =>-1),
					'E' 	=> Coord2D->new(col => 1, row => 0),
					'SE' 	=> Coord2D->new(col => 1, row => 1),
					'S' 	=> Coord2D->new(col => 0, row => 1),
					'SW' 	=> Coord2D->new(col =>-1, row => 1),
					'W' 	=> Coord2D->new(col =>-1, row => 0),
					'NW' 	=> Coord2D->new(col =>-1, row =>-1));
our %OFFSET_DIRS_3D = ('N' 	=> c3_make( 0,-1, 0),
						'NE' 	=> c3_make( 1,-1, 0),
						'E' 	=> c3_make( 1, 0, 0),
						'SE' 	=> c3_make( 1, 1, 0),
						'S' 	=> c3_make( 0, 1, 0),
						'SW' 	=> c3_make(-1, 1, 0),
						'W' 	=> c3_make(-1, 0, 0),
						'NW' 	=> c3_make(-1,-1, 0),
						'U' 	=> c3_make( 0, 0, 1),
						'NU' 	=> c3_make( 0,-1, 1),
						'NEU' 	=> c3_make( 1,-1, 1),
						'EU' 	=> c3_make( 1, 0, 1),
						'SEU' 	=> c3_make( 1, 1, 1),
						'SU' 	=> c3_make( 0, 1, 1),
						'SWU' 	=> c3_make(-1, 1, 1),
						'WU' 	=> c3_make(-1, 0, 1),
						'NWU' 	=> c3_make(-1,-1, 1),
						'D' 	=> c3_make( 0, 0,-1),
						'ND' 	=> c3_make( 0,-1,-1),
						'NED' 	=> c3_make( 1,-1,-1),
						'ED' 	=> c3_make( 1, 0,-1),
						'SED' 	=> c3_make( 1, 1,-1),
						'SD' 	=> c3_make( 0, 1,-1),
						'SWD' 	=> c3_make(-1, 1,-1),
						'WD' 	=> c3_make(-1, 0,-1),
						'NWD' 	=> c3_make(-1,-1,-1));

our %OFFSET_ALIASES = ('UP'	=> 'N', 'RIGHT' => 'E', 'DOWN' 	=> 'S', 'LEFT' 	=> 'W',
						'^' => 'N', '>' => 'E', 'v' => 'S', '<' => 'W',
						'U' => 'N', 'R' => 'E', 'D' => 'S', 'L' => 'W',);

# These are exposed through ROOK(), BISHOP(), QUEEN() below
my $ROOK = 'ROOK';
my $BISHOP = 'BISHOP';
my $QUEEN = 'QUEEN';
my %ADJACENCY_RULES = ('ROOK'    => ['N','E','S','W'],
						'BISHOP' => ['NE','SE','SW','NW'],
						'QUEEN'  => ['N','NE','E','SE','S','SW','W','NW']);
my %ADJACENCY_RULES_3D = ('ROOK'    => ['N','E','S','W','U','D'],
						  'BISHOP' => ['NEU','SEU','SWU','NWU','NED','SED','SWD','NWD'],
						  'QUEEN'  => ['N','NE','E','SE','S','SW','W','NW',
						  			   'NU','NEU','EU','SEU','SU','SWU','WU','NWU','U',
						  			   'ND','NED','ED','SED','SD','SWD','WD','NWD','D']);

# -------------------------------------------------------
# Coord2D
#
# Two-dimensional coordinate class
# -------------------------------------------------------
class Coord2D {
	field $col :param :reader;
	field $row :param :reader;

# 	method col() { return $col; }
# 	method row() { return $row; }
	method X() { return $col; }
	method Y() { return $row; }

	method add($other_coord) {
		return ::c2_make( $col + $other_coord->col(),
						  $row + $other_coord->row() );
	}

	method equals($other_coord) {
		return $col == $other_coord->col() &&
				$row == $other_coord->row();
	}

	method delta($other_coord) {
		return ::c2_make( $other_coord->col() - $col,
						  $other_coord->row() - $row );
	}

	method offset($dir_str) {
		# Return this Coord shifted in the direction
		my $off;
		my $resolved = ::d2_from_alias($dir_str);
		if (exists $OFFSET_DIRS{$resolved}) {
			$off = $OFFSET_DIRS{$resolved};
		}
		else {
			$off = ::c2_origin();
		}
		my $result = $self->add($off);
		return $result;
	}

	method is_adjacent($other_coord, $rule = $ROOK) {
		if ($rule eq $ROOK) {
			return $self->manhattan($other_coord) == 1;
		}
		elsif ($rule eq $BISHOP) {
			return abs($col - $other_coord->col()) == 1 &&
					abs($row - $other_coord->row()) == 1;
		}
		#QUEEN
		return ($self->manhattan($other_coord) == 1) ||
				(abs($col - $other_coord->col()) == 1 &&
				 abs($row - $other_coord->row()) == 1)
	}

	method get_adjacent_coords($rule = $ROOK) {
		my @result = ();
		if (exists $ADJACENCY_RULES{$rule}) {
			for my $dir (@{$ADJACENCY_RULES{$rule}}) {
				push(@result, $self->offset($dir));
			}
		}
		return @result;
	}

	method distance($other_coord) {
		my $delta = $self->delta($other_coord);
		return sqrt($delta->col()**2 + $delta->row()**2);
	}

	method manhattan($other_coord) {
		return abs($other_coord->col() - $col) + abs($other_coord->row() - $row);
	}

	method clone() {
		return Coord2D->new(col => $col, row => $row);
	}

	method to_str {
		return "[$col,$row]";
	}

	sub valid($var) {
		use Scalar::Util qw(reftype blessed);
		return (reftype($var) && reftype($var) eq 'OBJECT' && blessed($var) eq 'Coord2D');
	}
}

# -------------------------------------------------------
# Coord3D
#
# Three-dimensional coordinate class
# -------------------------------------------------------
class Coord3D {
	field $col :param :reader;
	field $row :param :reader;
	field $ht :param :reader;

	method X() { return $col; }
	method Y() { return $row; }
	method Z() { return $ht; }

	method add($other_coord) {
		return ::c3_make( $col + $other_coord->col(),
						  $row + $other_coord->row(),
						  $ht + $other_coord->ht() );
	}

	method equals($other_coord) {
		return $col == $other_coord->col() &&
				$row == $other_coord->row() &&
				$ht == $other_coord->ht();
	}

	method delta($other_coord) {
		return ::c3_make( $other_coord->col() - $col,
						  $other_coord->row() - $row,
						  $other_coord->ht() - $ht );
	}

	method is_adjacent($other_coord, $rule = $ROOK) {
		if ($rule eq $ROOK) {
			return $self->manhattan($other_coord) == 1;
		}
		elsif ($rule eq $BISHOP) {
			return abs($col - $other_coord->col()) == 1 &&
					abs($row - $other_coord->row()) == 1 &&
					abs($ht - $other_coord->ht()) == 1;
		}
		#QUEEN
		return ($self->manhattan($other_coord) == 1) ||
				(abs($col - $other_coord->col()) == 1 &&
				 abs($row - $other_coord->row()) == 1 &&
				 abs($ht - $other_coord->ht()) == 1);
	}

	method get_adjacent_coords($rule = $ROOK) {
		my @result = ();
		if (exists $ADJACENCY_RULES_3D{$rule}) {
			for my $dir (@{$ADJACENCY_RULES_3D{$rule}}) {
				push(@result, $self->offset($dir));
			}
		}
		return @result;
	}

	method distance($other_coord) {
		my $delta = $self->delta($other_coord);
		return sqrt($delta->col()**2 + $delta->row()**2 + $delta->ht()**2);
	}

	method manhattan($other_coord) {
		return abs($other_coord->col() - $col)
			 + abs($other_coord->row() - $row)
			 + abs($other_coord->ht() - $ht);
	}

	method coord2D() {
		return Coord2D->new(col => $col, row => $row);
	}

	method clone() {
		return Coord3D->new(col => $col, row => $row, ht => $ht);
	}

	method to_str {
		return "[$col,$row,$ht]";
	}

	sub valid($var) {
		use Scalar::Util qw(reftype blessed);
		return (reftype($var) && reftype($var) eq 'OBJECT' && blessed($var) eq 'Coord3D');
	}

}

# -------------------------------------------------------
# Position
#
# Two-dimensional coordinate with a direction
# -------------------------------------------------------
class Position {
	use List::Util qw(first);
	field $coord :param :reader;
	field $dir :reader :param = 'N';

	ADJUST {
		$dir = ::d2_from_alias($dir);
	}

# 	method coord() { return $coord; }
# 	method dir() { return $dir; }

	method equals($other_pos) {
		return $coord->equals($other_pos->coord()) &&
				$dir eq $other_pos->dir();
	}

	method turn($rot_str) {
		my $new_dir = Position->turn_str($rot_str, $dir);
		return Position->new(coord => $coord->clone(), dir => $new_dir);
	}

	sub turn_str($cls, $rot_str, $dir) {
		my $step = 0;
		$step = 1 if first { $_ eq $rot_str } ('CW', 'RIGHT', 'R');
		$step = -1 if first { $_ eq $rot_str } ('CCW', 'LEFT', 'L');
		my @ordered = @{$ADJACENCY_RULES{$ROOK}}; # ('N', 'E', 'S', 'W');
		my $index = List::Util::first { $ordered[$_] eq $dir } 0..$#ordered;
		return $dir if $index < 0; # Direction isn't one of NESW
		$index = ($index + $step) % 4;
		return $ordered[$index];
	}

	method move_forward($distance = 1) {
		my $move;
		if (exists $OFFSET_DIRS{$dir}) {
			my $off = $OFFSET_DIRS{$dir};
			$move = Coord2D->new( col => $off->col() * $distance,
								row => $off->row() * $distance );
		}
		else { $move = ::c2_origin(); } # zero

		my $new_coord = $coord->add($move);
		return Position->new( coord => $new_coord, dir => $dir );
	}

	method clone() {
		return ::p2_make($coord, $dir);
	}

	method to_str() {
		return '{' . $coord->to_str() . ' ' . $dir . '}';
	}

	sub valid($var) {
		use Scalar::Util qw(reftype blessed);
		return (reftype($var) && reftype($var) eq 'OBJECT' && blessed($var) eq 'Position');
	}
}


# -------------------------------------------------------
# Extent1D
#
# One-dimensional extent (i.e. a range)
# -------------------------------------------------------
class Extent1D {
	field $_min :param(min);
	field $_max :param(max);

	ADJUST {
		if ($_min > $_max) {
			my $temp = $_min; $_min = $_max; $_max = $temp;
		}
	}

	method min() { return $_min; }
	method max() { return $_max; }

	method equals($other) {
		if (!Extent1D::valid($other)) { return 0; }
		return $_min == $other->min() && $_max == $other->max();
	}

	method size() {
		return $_max - $_min + 1;
	}

	method contains($other) {
		use Scalar::Util qw(looks_like_number);
		# A number
		if (ref $other eq "" && looks_like_number($other)) {
			return $_min <= $other && $other <= $_max;
		}
		# Another Extent
		if (Extent1D::valid($other)) {
			return $_min <= $other->min() && $other->max() <= $_max;
		}
		return 0;
	}

	method overlaps($other) {
		if (!Extent1D::valid($other)) { return 0; }
		return 1 if $self->intersect($other);
		return 0;
	}

	method union($other) {
		if (!Extent1D::valid($other)) { return 0; }
		my $min = List::Util::min($_min, $other->min());
		my $max = List::Util::max($_max, $other->max());
		return Extent1D->new(min => $min, max => $max);
	}

	method intersect($other) {
		if (!Extent1D::valid($other)) { return 0; }
		my $bigmin = List::Util::max($_min, $other->min());
		my $smallmax = List::Util::min($_max, $other->max());
		if ($bigmin <= $smallmax) {
			return Extent1D->new(min => $bigmin, max => $smallmax);
		}
		return 0; #empty
	}

	method clone() {
		return ::e1_make($_min, $_max);
	}

	method to_str() {
		return "{min: $_min, max: $_max}";
	}

	sub valid($var) {
		use Scalar::Util qw(reftype blessed);
		return (reftype($var) && reftype($var) eq 'OBJECT' && blessed($var) eq 'Extent1D');
	}
}


# -------------------------------------------------------
# Extent2D
#
# Two-dimensional extent
# -------------------------------------------------------
class Extent2D {
	field $_min :param(min);
	field $_max :param(max);

	ADJUST {
		# Because the constructor is protected by scope, and e2_make makes sure
		# that the min and max are actually the min and max, not going to put
		# any sanity code here.
	}

# 	method min() { return $_min; }
# 	method max() { return $_max; }

	method nw() { return $_min; }
	method se() { return $_max; }
	method ne() { return ::c2_make($_max->X(), $_min->Y()); }
	method sw() { return ::c2_make($_min->X(), $_max->Y()); }

	method xmin() { return $_min->X() }
	method xmax() { return $_max->X() }
	method ymin() { return $_min->Y() }
	method ymax() { return $_max->Y() }

	method equals($other) {
		if (!Extent2D::valid($other)) { return 0; }
		return $_min->equals($other->nw()) && $_max->equals($other->se());
	}

	method width() {
		return $_max->X() - $_min->X() + 1;
	}

	method height() {
		return $_max->Y() - $_min->Y() + 1;
	}

	method area() {
		return $self->width() * $self->height();
	}

	method expanded($to_fit_coord) {
		use List::Util qw(max min);
		if (!Coord2D::valid($to_fit_coord)) {
			return $self->clone();
		}
		return ::e2_make($_min, $_max, $to_fit_coord);
	}

	method inset($amt) {
		my $n = $_min->Y() + $amt;
		my $w = $_min->X() + $amt;
		my $s = $_max->Y() - $amt;
		my $e = $_max->X() - $amt;
		if ($n > $s || $w > $e) { return 0; }
		return ::e2_make(::c2_make($w, $n), ::c2_make($e, $s));
	}

	method all_coords() {
		my @coords = ();
		for (my $x = $_min->X(); $x <= $_max->X(); $x++) {
			for (my $y = $_min->Y(); $y <= $_max->Y(); $y++) {
				push( @coords, ::c2_make($x, $y) );
			}
		}
		return @coords;
	}

	method contains($coord) {
		# A Coord2D
		if (Coord2D::valid($coord)) {
			return $_min->X() <= $coord->X() && $coord->X() <= $_max->X() &&
					$_min->Y() <= $coord->Y() && $coord->Y() <= $_max->Y();
		}
		return 0;
	}

	method overlaps($other) {
		if (!Extent2D::valid($other)) { return 0; }
		return 1 if $self->intersect($other);
		return 0;
	}

	method union($other) {
		if (!Extent2D::valid($other)) { return 0; }
		#say "union of " . $self->to_str() . " and " . $other->to_str();
		if ($self->equals($other)) { return $self->clone(); }

		my @results = ();
		my $e_int = $self->intersect($other);
		if (!valid($e_int)) {
			#say "no valid intersection. Returning clones of self and other";
			push( @results, $self->clone(), $other->clone() );
			return @results;
		}
		#say "the intersection is " . $e_int->to_str();

		push( @results, $e_int );
		for my $e ( $self, $other ) {
			if ($e->equals($e_int)) { next; }

			if ($e->nw()->X() < $e_int->nw()->X()) { # xmin
				if ($e->nw()->Y() < $e_int->nw()->Y()) { # ymin
					push( @results, ::e2_from_ints($e->nw()->X(), $e->nw()->Y(), $e_int->nw()->X()-1, $e_int->nw()->Y()-1) );
				}
				if ($e->se()->Y() > $e_int->se()->Y()) { # ymax
					push( @results, ::e2_from_ints($e->nw()->X(), $e_int->se()->Y()+1, $e_int->nw()->X()-1, $e->se()->Y()) );
				}
				push( @results, ::e2_from_ints($e->nw()->X(), $e_int->nw()->Y(), $e_int->nw()->X()-1, $e_int->se()->Y()) );
			}
			if ($e_int->se()->X() < $e->se()->X()) {
				if ($e->nw()->Y() < $e_int->nw()->Y()) { # ymin
					push( @results, ::e2_from_ints($e_int->se()->X()+1, $e->nw()->Y(), $e->se()->X(), $e_int->nw()->Y()-1) );
				}
				if ($e->se()->Y() > $e_int->se()->Y()) { # ymax
					push( @results, ::e2_from_ints($e_int->se()->X()+1, $e_int->se()->Y()+1, $e->se()->X(), $e->se()->Y()) );
				}
				push( @results, ::e2_from_ints($e_int->se()->X()+1, $e_int->nw()->Y(), $e->se()->X(), $e_int->se()->Y()) );
			}
			if ($e->nw()->Y() < $e_int->nw()->Y()) { #ymin
				push( @results, ::e2_from_ints($e_int->nw()->X(), $e->nw()->Y(), $e_int->se()->X(), $e_int->nw()->Y()-1) );
			}
			if ($e_int->se()->Y() < $e->se()->Y()) { #ymax
				push( @results, ::e2_from_ints($e_int->nw()->X(), $e_int->se()->Y()+1, $e_int->se()->X(), $e->se()->Y()) );
			}
		}
		return @results;
	}

	method intersect($other) {
		use List::Util qw(max min);
		if (!Extent2D::valid($other)) { return 0; }
		my $common_min_x = max($_min->X(), $other->nw()->X());
		my $common_max_x = min($_max->X(), $other->se()->X());
		if ($common_max_x < $common_min_x) { return 0; }
		my $common_min_y = max($_min->Y(), $other->nw()->Y());
		my $common_max_y = min($_max->Y(), $other->se()->Y());
		if ($common_max_y < $common_min_y) { return 0; }

		return ::e2_make(::c2_make($common_min_x, $common_min_y), ::c2_make($common_max_x, $common_max_y));
	}

	method clone() {
		return ::e2_make($_min, $_max);
	}

	method to_str() {
		return "{min: ". $_min->to_str() . ", max: " . $_max->to_str() . "}";
	}

	sub valid($var) {
		use Scalar::Util qw(reftype blessed);
		return (reftype($var) && reftype($var) eq 'OBJECT' && blessed($var) eq 'Extent2D');
	}
}


# -------------------------------------------------------
# Extent3D
#
# Three-dimensional extent
# -------------------------------------------------------
class Extent3D {
	field $_min :param(min);
	field $_max :param(max);

	ADJUST {
		# Because the constructor is protected by scope, and e2_make makes sure
		# that the min and max are actually the min and max, not going to put
		# any sanity code here.
	}

	method nwd() { return $_min; }
	method ned() { return ::c3_make($_max->X(), $_min->Y(), $_min->Z()) }
	method swd() { return ::c3_make($_min->X(), $_max->Y(), $_min->Z()) }
	method sed() { return ::c3_make($_max->X(), $_max->Y(), $_min->Z()) }

	method seu() { return $_max; }
	method neu() { return ::c3_make($_max->X(), $_min->Y(), $_max->Z()) }
	method swu() { return ::c3_make($_min->X(), $_max->Y(), $_max->Z()) }
	method nwu() { return ::c3_make($_min->X(), $_min->Y(), $_max->Z()) }

	method xmin() { return $_min->X() }
	method xmax() { return $_max->X() }
	method ymin() { return $_min->Y() }
	method ymax() { return $_max->Y() }
	method zmin() { return $_min->Z() }
	method zmax() { return $_max->Z() }


	method equals($other) {
		if (!Extent3D::valid($other)) { return 0; }
		return $_min->equals($other->nwd()) && $_max->equals($other->sed());
	}

	method width() {
		return $_max->X() - $_min->X() + 1;
	}

	method height() {
		return $_max->Y() - $_min->Y() + 1;
	}

	method depth() {
		return $_max->Z() - $_min->Z() + 1;
	}

	method volume() {
		return $self->width() * $self->height() * $self->depth();
	}

	method verticalExtent() {
		return Extent1D->new(min => $_min->Z(), max => $_max->Z());
	}

	method extent2D() {
		return Extent2D->new(min => $_min->coord2D(), max => $_max->coord2D());
	}

	method contains($coord) {
		# A Coord3D
		if (Coord3D::valid($coord)) {
			return  $_min->X() <= $coord->X() && $coord->X() <= $_max->X() &&
					$_min->Y() <= $coord->Y() && $coord->Y() <= $_max->Y() &&
					$_min->Z() <= $coord->Z() && $coord->Z() <= $_max->Z();
		}
		return 0;
	}

	method overlaps($other) {
		if (!Extent3D::valid($other)) { return 0; }
		return 1 if $self->intersect($other);
		return 0;
	}

	method intersect($other) {
		use List::Util qw(max min);
		if (!Extent3D::valid($other)) { return 0; }
		my $common_min_x = max($_min->X(), $other->nwd()->X());
		my $common_max_x = min($_max->X(), $other->seu()->X());
		if ($common_max_x < $common_min_x) { return 0; }
		my $common_min_y = max($_min->Y(), $other->nwd()->Y());
		my $common_max_y = min($_max->Y(), $other->seu()->Y());
		if ($common_max_y < $common_min_y) { return 0; }
		my $common_min_z = max($_min->Z(), $other->nwd()->Z());
		my $common_max_z = min($_max->Z(), $other->seu()->Z());
		if ($common_max_z < $common_min_z) { return 0; }

		return ::e3_make(::c3_make($common_min_x, $common_min_y, $common_min_z),
						 ::c3_make($common_max_x, $common_max_y, $common_max_z));
	}

	method clone() {
		return ::e3_make($_min, $_max);
	}

	method to_str() {
		return "{min: ". $_min->to_str() . ", max: " . $_max->to_str() . "}";
	}

	sub valid($var) {
		use Scalar::Util qw(reftype blessed);
		return (reftype($var) && reftype($var) eq 'OBJECT' && blessed($var) eq 'Extent3D');
	}
}

# -------------------------------------------------------
# Functions
#   have to be below all class definitions
# -------------------------------------------------------

sub ROOK()		{ return $ROOK; }
sub BISHOP()	{ return $BISHOP; }
sub QUEEN()		{ return $QUEEN; }

sub c2_make($x, $y) {
	return Coord2D->new(col=>$x, row=>$y);
}

sub c2_from_str($val) {
	if ($val =~ m/\[(-?\d+),(-?\d+)\]/) {
		return Coord2D->new(col => $1, row => $2);
	}
	return 0;
}

sub c2_origin() {
	return c2_make(0,0);
}

sub c2_is_valid($c) {
	return Coord2D::valid($c);
}

sub c3_make($x, $y, $z) {
	return Coord3D->new(col=>$x, row=>$y, ht=>$z);
}

sub c3_from_str($val) {
	if ($val =~ m/\[(-?\d+),(-?\d+),(-?\d+)\]/) {
		return Coord3D->new(col => $1, row => $2, ht => $3);
	}
	return 0;
}

sub c3_origin() {
	return c3_make(0,0,0);
}

sub c3_is_valid($c) {
	return Coord3D::valid($c);
}

sub xy_offset($dir_str) {
	my $off;
	my $resolved = ::d2_from_alias($dir_str);
	if (exists $OFFSET_DIRS{$resolved}) {
		$off = $OFFSET_DIRS{$resolved};
	}
	else {
		$off = ::c2_origin();
	}
	return ($off->X(), $off->Y());
}

sub xy_offsets($rule = $ROOK) {
	my @result = ();
	if (exists $ADJACENCY_RULES{$rule}) {
		for my $dir (@{$ADJACENCY_RULES{$rule}}) {
			my @xy = xy_offset($dir);
			push(@result, \@xy);
		}
	}
	return @result;
}

sub d2_from_alias($dir) {
	if (exists $OFFSET_DIRS{$dir}) {
		return $dir;
	}
	elsif (exists $OFFSET_ALIASES{$dir}) {
		return $OFFSET_ALIASES{$dir};
	}
	return "";
}

sub d2_for_rule($rule) {
	if (exists $ADJACENCY_RULES{$rule}) {
		return @{$ADJACENCY_RULES{$rule}};
	}
	return ();
}

sub d2_turn($from_dir, $by_degrees) {
	my @dirs = @{$ADJACENCY_RULES{$QUEEN}};
	my $idx = first {$dirs[$_] eq $from_dir} 0..$#dirs;
	my $clicks = int($by_degrees / 45);
	my $new_idx = ($idx + $clicks) % 8;
	return $dirs[$new_idx];
}

sub d2_opposite($dir) {
	return d2_turn($dir, 180);
# 	my @dirs = @{$ADJACENCY_RULES{$QUEEN}};
# 	my $idx = first {$dirs[$_] eq $dir} 0..$#dirs;
# 	my $opp_idx = ($idx + 4) % 8;
# 	return $dirs[$opp_idx];
}

sub p2_make($coord, $dir = 'N') {
	return Position->new(coord => $coord, dir => $dir);
}

sub e1_make($min, $max) {
	return Extent1D->new(min => $min, max => $max);
}

sub e1_is_valid($e1d) {
	return Extent1D::valid($e1d);
}

sub e2_make(@coords) {
	my @x = sort {$a <=> $b} (map { $_->X() } @coords);
	my @y = sort {$a <=> $b} (map { $_->Y() } @coords);
	my $nw = ::c2_make($x[0], $y[0]);
	my $se = ::c2_make($x[-1], $y[-1]);
	return Extent2D->new(min => $nw, max => $se);
}

sub e2_from_ints($xmin, $ymin, $xmax, $ymax) {
	my $nw = ::c2_make($xmin, $ymin);
	my $se = ::c2_make($xmax, $ymax);
	return ::e2_make($nw, $se); # Don't trust the inputs
}

sub e2_is_valid($e2d) {
	return Extent2D::valid($e2d);
}

sub e3_make(@coords) {
	my @x = sort {$a <=> $b} (map { $_->X() } @coords);
	my @y = sort {$a <=> $b} (map { $_->Y() } @coords);
	my @z = sort {$a <=> $b} (map { $_->Z() } @coords);
	my $nwd = ::c3_make($x[0], $y[0], $z[0]);
	my $seu = ::c3_make($x[-1], $y[-1], $z[-1]);
	return Extent3D->new(min => $nwd, max => $seu);
}

sub e3_from_ints($xmin, $ymin, $xmax, $ymax, $zmin, $zmax) {
	my $nwd = ::c3_make($xmin, $ymin, $zmin);
	my $seu = ::c3_make($xmax, $ymax, $zmax);
	return ::e3_make($nwd, $seu); # Don't trust the inputs
}

sub e3_is_valid($e3d) {
	return Extent3D::valid($e3d);
}



1;
