#!/usr/bin/env perl
use v5.42;
use feature 'class';
no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;

use AOC::Util;

my $DAY = sprintf("%02d", 7);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../input/$INPUT_FILE");

say "Advent of Code 2023, Day 7: Camel Cards";



my $cch = CamelCardHand->new("str" => "4Q6Q6");
p $cch;
p $cch->cards()->[0]->value();
p $cch->type()->type();

solve_part_one(@input);
#solve_part_two(@input);

exit( 0 );


class CamelCard {
	field $face :param :reader;
	field $value :reader = 0;

	ADJUST {
		if ($face =~ m/\d+/g) {
			$value = $face + 0;
		}
		elsif ($face eq 'J') { $value = 11; }
		elsif ($face eq 'Q') { $value = 12; }
		elsif ($face eq 'K') { $value = 13; }
		elsif ($face eq 'A') { $value = 14; }
	}

	method compare($other_cc) {
		return $value <=> $other_cc->value();
	}
}

class CamelCardHandType {
	field $type :param :reader;
	field $value :reader = 0;

	ADJUST {
		$type = uc($type);
		if 		($type eq '5 OF A KIND') 	{ $value = 6; }
		elsif 	($type eq '4 OF A KIND') 	{ $value = 5; }
		elsif 	($type eq 'FULL HOUSE') 	{ $value = 4; }
		elsif 	($type eq '3 OF A KIND') 	{ $value = 3; }
		elsif 	($type eq '2 PAIR') 		{ $value = 2; }
		elsif 	($type eq '1 PAIR') 		{ $value = 1; }
		# elsif 	($type eq 'HIGH CARD') 		{ $value = 0; }
	}

	method compare($other_ccht) {
		return $value <=> $other_ccht->value();
	}

	sub determine_type( $cls, @cards ) {
		my @faces = map { $_->face() } @cards;
		my %hist = ();
		for my $face (@faces) {
			$hist{$face}++;
		}

		# How many unique cards are in the hand?
		my $face_count = scalar values %hist;

		if ($face_count == 1) {
			return CamelCardHandType->new(type => '5 OF A KIND');
		}
		elsif ($face_count == 2) {
			if (grep { $_ == 4 } values %hist) {
				return CamelCardHandType->new(type => '4 OF A KIND');
			}
			return return CamelCardHandType->new(type => 'FULL HOUSE');
		}
		elsif ($face_count == 3) {
			if (grep { $_ == 3 } values %hist) {
				return CamelCardHandType->new(type => '3 OF A KIND');
			}
			return return CamelCardHandType->new(type => '2 PAIR');
		}
		elsif ($face_count == 4) {
			return CamelCardHandType->new(type => '1 PAIR');
		}
		return CamelCardHandType->new(type => 'HIGH CARD');
	}
}

class CamelCardHand {
	field $str :param;
	field $cards :reader;
	field $type :reader;

	ADJUST {
		say $str;
		my @faces = split(//, $str);
		my @c = map { CamelCard->new(face => $_) } @faces;
		$cards = \@c;
		$type = CamelCardHandType->determine_type( @c );
	}
}

sub solve_part_one(@input) {

	say "Part One: ";
}

sub solve_part_two(@input) {

	say "Part Two: ";
}
