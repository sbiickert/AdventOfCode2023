#!/usr/bin/env perl
use v5.40;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
#use Data::Printer;
#use Storable 'dclone';

use AOC::Util;
#use AOC::Geometry;
#use AOC::Grid;

my $INPUT_FILE = 'day<##>_test.txt';
#my $INPUT_FILE = 'day<##>_challenge.txt';
my @input = read_input("../input/$INPUT_FILE");

say "Advent of Code 2023, Day <##>: <##>";

solve_part_one(@input);
#solve_part_two(@input);

exit( 0 );

sub solve_part_one(@input) {

	say "Part One: ";
}

sub solve_part_two(@input) {

	say "Part One: ";
}
