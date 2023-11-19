use Modern::Perl 2023;

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory;

package AOC::Grid;
use Exporter;
use feature 'signatures';
use AOC::Geometry;

our @ISA = qw( Exporter );
#our @EXPORT_OK = qw(g2_make);
our @EXPORT = qw(
	g2_make g2_get_default g2_get_rule

	g2_get g2_get_scalar g2_set g2_clear g2_extent
	g2_coords g2_coords_with_value g2_histogram
	g2_offsets g2_neighbors

	g2_print g2_to_str);


# -------------------------------------------------------
# Grid2D
#
# Data model: array reference [data hashref, default, rule, extent]
# -------------------------------------------------------

our @RULES = ('rook', 'bishop', 'queen');

sub g2_make($default, $adj_rule) {
	if ( !grep( /^$adj_rule$/, @RULES ) ) {
		die "$adj_rule is not a valid adjacency rule: @RULES";
	}
	my $g2d = [{}, $default, $adj_rule, []];
}

sub g2_get_default($g2d) {
	return $g2d->[1];
}

sub g2_get_rule($g2d) {
	return $g2d->[2];
}

sub g2_get($g2d, $c2d) {
	my $key = c2_to_str($c2d);
	my $val = exists( $g2d->[0]{$key} ) ? $g2d->[0]{$key} : $g2d->[1];
	return $val;
}

# If the underlying data is array refs or hash refs, return a meaningful scalar
sub g2_get_scalar($g2d, $c2d) {
	my $key = c2_to_str($c2d);
	my $val = g2_get($g2d, $c2d);
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

sub g2_set($g2d, $c2d, $val) {
	my $key = c2_to_str($c2d);
	$g2d->[0]{$key} = $val;
	my $expanded = e2_expanded_to_fit( g2_extent($g2d), $c2d );
	g2_set_extent($g2d, $expanded);
}

sub g2_clear($g2d, $c2d, $reset_extent = 0) {
	my $key = c2_to_str($c2d);
	delete $g2d->[0]{$key};
	g2_reset_extent($g2d) if $reset_extent;
}

sub g2_extent($g2d) {
	my $current = $g2d->[3];
	if (e2_is_empty($current)) {
		return [];
	}
	return e2_make(e2_min($current), e2_max($current));
}

# Symbol not exported, private
sub g2_set_extent($g2d, $e2d) {
	$g2d->[3] = $e2d;
}

# Symbol not exported, private
sub g2_reset_extent($g2d) {
	g2_set_extent($g2d, e2_build( g2_coords($g2d) ));
}

sub g2_coords($g2d) {
	my @coords = ();
	for my $key (keys(%{$g2d->[0]})) {
		push( @coords, c2_from_str($key) );
	}
	return @coords;
}

sub g2_coords_with_value($g2d, $val) {
	my @coords = ();
	for my $key (keys(%{$g2d->[0]})) {
		if ($g2d->[0]{$key} eq $val) {
			push( @coords, c2_from_str($key) );
		}
	}
	return @coords;
}

sub g2_histogram($g2d) {
	my $hist = {};
	for my $c ( e2_all_coords( g2_extent($g2d) ) ) {
		my $val = g2_get_scalar($g2d, $c);
		$hist->{$val} ++;
	}
	return $hist;
}

sub g2_offsets($g2d) {
	my @offsets = ();

	my $rule = $g2d->[2];
	if ($rule eq 'rook' || $rule eq 'queen') {
		push( @offsets, (c2_offset('N'), c2_offset('E'), c2_offset('S'), c2_offset('W')) );
	}
	if ($rule eq 'bishop' || $rule eq 'queen') {
		push( @offsets, (c2_offset('NW'), c2_offset('NE'), c2_offset('SE'), c2_offset('SW')) );
	}
	return @offsets;
}

sub g2_neighbors($g2d, $c2d) {
	my @offsets = g2_offsets($g2d);
	my @neighbors = ();

	for my $o (@offsets) {
		push( @neighbors, c2_add( $c2d, $o ));
	}
	return @neighbors;
}

sub g2_print($g2d, $markers=0, $invert_y=0) {
	print g2_to_str($g2d, $markers, $invert_y);
}

sub g2_to_str($g2d, $markers=0, $invert_y=0) {
	my $str = '';
	my $e2d = g2_extent($g2d);
	my $ymin = $e2d->[1];
	my $ymax = $e2d->[3];
	if ($invert_y) {
		for (my $y = $ymax; $y >= $ymin; $y--) {
			my @row = ();
			for (my $x = $e2d->[0]; $x <= $e2d->[2]; $x++) {
				my $c = c2_make($x, $y);
				my $glyph = g2_get_scalar($g2d, $c);
				if ($markers && defined $markers->{c2_to_str($c)}) {
					$glyph = $markers->{c2_to_str($c)};
				}
				push( @row, $glyph );
			}
			push (@row, "\n");
			$str .= join(' ', @row);
		}
	}
	else {
		for (my $y = $ymin; $y <= $ymax; $y++) {
			my @row = ();
			for (my $x = $e2d->[0]; $x <= $e2d->[2]; $x++) {
				my $c = c2_make($x, $y);
				my $glyph = g2_get_scalar($g2d, $c);
				if ($markers && defined $markers->{c2_to_str($c)}) {
					$glyph = $markers->{c2_to_str($c)};
				}
				push( @row, $glyph );
			}
			push (@row, "\n");
			$str .= join(' ', @row);
		}
	}
	return $str;
}

