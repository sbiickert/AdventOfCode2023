use v5.40;
use feature 'class';
no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory;

package AOC::Geometry;
use Exporter;
#use Data::Dumper;
#use Storable 'dclone';

our @ISA = qw( Exporter );
#our @EXPORT_OK = qw(c2_make c3_make);
our @EXPORT = qw(
	ROOK BISHOP QUEEN
	c2_make c2_from_str c2_origin c2_is_valid
	d2_from_alias
	p2_make
	e1_make e1_is_valid
	e2_make e2_from_ints e2_is_valid
);

our %OFFSET_DIRS = ('N' 	=> Coord2D->new(col => 0, row => -1),
					'NE' 	=> Coord2D->new(col => 1, row =>-1),
					'E' 	=> Coord2D->new(col => 1, row => 0),
					'SE' 	=> Coord2D->new(col => 1, row => 1),
					'S' 	=> Coord2D->new(col => 0, row => 1),
					'SW' 	=> Coord2D->new(col =>-1, row => 1),
					'W' 	=> Coord2D->new(col =>-1, row => 0),
					'NW' 	=> Coord2D->new(col =>-1, row =>-1));

our %OFFSET_ALIASES = ('UP'	=> 'N', 'RIGHT' => 'E', 'DOWN' 	=> 'S', 'LEFT' 	=> 'W',
						'^' => 'N', '>' => 'E', 'v' => 'S', '<' => 'W');

# These are exposed through ROOK(), BISHOP(), QUEEN() below
my $ROOK = 'ROOK';
my $BISHOP = 'BISHOP';
my $QUEEN = 'QUEEN';
my %ADJACENCY_RULES = ('ROOK'    => ['N','E','S','W'],
						'BISHOP' => ['NE','SE','SW','NW'],
						'QUEEN'  => ['N','NE','E','SE','S','SW','W','NW']);

# -------------------------------------------------------
# Coord2D
#
# Two-dimensional coordinate class
# -------------------------------------------------------
class Coord2D {
	field $col :param;
	field $row :param;

	method col() { return $col; }
	method row() { return $row; }
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
		my $delta = $self->delta($other_coord);
		return abs($delta->col()) + abs($delta->row());
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
# Position
#
# Two-dimensional coordinate with a direction
# -------------------------------------------------------
class Position {
	use List::Util qw(first);
	field $coord :param;
	field $dir :param = 'N';

	ADJUST {
		$dir = ::d2_from_alias($dir);
	}

	method coord() { return $coord; }
	method dir() { return $dir; }

	method equals($other_pos) {
		return $coord->equals($other_pos->coord()) &&
				$dir eq $other_pos->dir();
	}

	method turn($rot_str) {
		my $step = 0;
		$step = 1 if first { $_ eq $rot_str } ('CW', 'RIGHT', 'R');
		$step = -1 if first { $_ eq $rot_str } ('CCW', 'LEFT', 'L');
		my @ordered = @{$ADJACENCY_RULES{$ROOK}}; # ('N', 'E', 'S', 'W');
		my $index = List::Util::first { $ordered[$_] eq $dir } 0..$#ordered;
		if ($index < 0) {
			# Direction isn't one of NESW
			return Position->new(coord => $coord->clone(), dir => $dir);
		}
		$index = ($index + $step) % 4;
		return Position->new(coord => $coord->clone(), dir => $ordered[$index]);
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

sub d2_from_alias($dir) {
	if (exists $OFFSET_DIRS{$dir}) {
		return $dir;
	}
	elsif (exists $OFFSET_ALIASES{$dir}) {
		return $OFFSET_ALIASES{$dir};
	}
	return "";
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



1;