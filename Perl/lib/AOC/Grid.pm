use v5.40;
use feature 'class';
no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory;

package AOC::Grid;
use Exporter;
use AOC::Geometry;

our @ISA = qw( Exporter );
#our @EXPORT_OK = qw(g2_make);
our @EXPORT = qw( g2_make );


# -------------------------------------------------------
# Grid2D
#
# Data model: array reference [data hashref, default, rule, extent]
# -------------------------------------------------------
class Grid2D {
	field %data = ();
	field $default :reader :param = '.';
	field $rule :reader :param = ::ROOK(); # from AOC::Geometry
	field $extent;

	ADJUST {
		if ( !grep( /^$rule$/, (::ROOK(), ::BISHOP(), ::QUEEN()) ) ) {
			say "$rule is not a valid adjacency rule. Defaulting to ROOK().";
			$rule = ::ROOK();
		}
	}

# 	method default() { return $default; }
# 	method rule() { return $rule; }
	method extent {
		if (!::e2_is_valid($extent)) {
			return 0;
		}
		return $extent->clone();
	}

	method get($coord) {
		my $key = ::c2_is_valid($coord) ? $coord->to_str() : "$coord";
		my $val = exists( $data{$key} ) ? $data{$key} : $default;
		return $val;
	}

	# If the underlying data is array refs or hash refs, return a meaningful scalar
	method get_scalar($coord) {
		my $val = $self->get($coord);
		my $r = ref $val;
		if ($r eq "") {
			return $val;
		}
		if ($r eq "ARRAY") {
			# Return item in [0]
			return $val->[0];
		}
		elsif ($r eq "HASH") {
			# Return item in {"glyph"}
			return $val->{"glyph"};
		}
		return "?";
	}

	method set($coord, $value) {
		if (!::c2_is_valid($coord)) { say "Invalid coord passed to Grid2D::set"; return; }
		my $key = $coord->to_str();
		$data{$key} = $value;

		# Update the extent to include the $coord
		my $new_extent = $extent;
		if (::e2_is_valid($extent)) {
			if (!$extent->contains($coord)) {
				$new_extent = $extent->expanded($coord);
			}
		}
		else {
			$new_extent = ::e2_make($coord, $coord)
		}
		$self->set_extent($new_extent);
	}

	method clear($coord, $reset_extent = 0) {
		my $key = ::c2_is_valid($coord) ? $coord->to_str() : "$coord";
		delete $data{$key};
		$self->reset_extent() if $reset_extent;
	}

	method set_extent($ext) {
		if (!::e2_is_valid($ext)) { $ext = 0; }
		$extent = $ext;
	}

	method reset_extent() {
		$self->set_extent( ::e2_make($self->coords()) );
	}

	method coords($with_val = undef) {
		my @coords = ();
		for my $key (keys %data) {
			if (!defined($with_val) || $data{$key} eq $with_val) {
				push( @coords, ::c2_from_str($key) );
			}
		}
		return @coords;
	}

	method histogram($include_unset = 0) {
		my $hist = {};
		my @coords_to_summarize = ();
		if ($include_unset) {
			if (::e2_is_valid($extent)) {
				@coords_to_summarize = $extent->all_coords();
			}
		}
		else {
			@coords_to_summarize = $self->coords();
		}
		for my $c ( @coords_to_summarize ) {
			my $val = $self->get_scalar($c);
			$hist->{$val} ++;
		}
		return $hist;
	}

	method neighbors($coord) {
		if (!::c2_is_valid($coord)) { return (); }
		return $coord->get_adjacent_coords($rule);
	}

	method print($markers=0, $invert_y=0) {
		print($self->to_str($markers, $invert_y));
	}

	method to_str($markers=0, $invert_y=0) {
		my $str = "";
		if (!::e2_is_valid($extent)) { return $str; }

		my $xmin = $extent->nw->X();
		my $xmax = $extent->se->X();
		my $ymin = $extent->nw->Y();
		my $ymax = $extent->se->Y();

		my @indexes = ();
		for my $r ( $ymin..$ymax ) { push(@indexes, $r); }
		if ($invert_y) { @indexes = reverse(@indexes); }

		for my $y (@indexes) {
			my @row = ();
			for my $x ($xmin..$xmax) {
				my $c = ::c2_make($x, $y);
				my $glyph = $self->get_scalar($c);
				if ($markers && defined $markers->{$c->to_str()}) {
					$glyph = $markers->{$c->to_str()};
				}
				push( @row, $glyph );
			}
			push (@row, "\n");
			$str .= join(' ', @row);
		}
		return $str;
	}

	method load(@rows) {
		for my $r (0..$#rows) {
			my $max_col = length($rows[0])-1;
			for my $c (0..$max_col) {
				my $char = substr($rows[$r], $c, 1);
				if ($char ne $default) {
					$self->set(::c2_make($c, $r), $char);
				}
			}
		}
	}
}


# -------------------------------------------------------
# Functions
#   have to be below all class definitions
# -------------------------------------------------------


sub g2_make($default = '.', $adj_rule = ::ROOK()) {
	return Grid2D->new(rule => $adj_rule, default => $default);
}

1;