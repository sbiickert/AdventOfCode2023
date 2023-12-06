#!/usr/bin/env perl
use Modern::Perl 2023;
our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
#use Data::Dumper;
#use Storable 'dclone';

use AOC::Util;
#use AOC::Geometry;
#use AOC::Grid;

my $INPUT_FILE = 'day01_test.txt';
#my $INPUT_FILE = 'day01_challenge.txt';
my $INDEX = 0;

my @input = read_grouped_input("../input/$INPUT_FILE", $INDEX);

say "Advent of Code 2023, Day 01: Trebuchet!?";

solve_part_one(@input);
#solve_part_two(@input);

exit( 0 );

sub solve_part_one(@input) {

}

sub solve_part_two(@input) {

}
