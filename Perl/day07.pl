#!/usr/bin/env perl
use v5.42;
use feature 'class';
no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'sum';

use AOC::Util;

my $DAY = sprintf("%02d", 7);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_input("../input/$INPUT_FILE");

say "Advent of Code 2023, Day 7: Camel Cards";

my @hands = map { CamelCardHand->new(str => $_) } @input;

my $p1 = solve_part(0, @hands);
say "Part One: the total winnings are $p1.";
my $p2 = solve_part(1, @hands);
say "Part One: the total winnings with Jokers are $p2.";

exit( 0 );


sub solve_part($use_jokers, @hands) {
	my @sorted = sort {return $a->compare($b, $use_jokers)} @hands;
	my @winnings = ();
	for my $i (0..$#sorted) {
		# say $sorted[$i]->debug_str($use_jokers);
		$winnings[$i] = $sorted[$i]->bid() * ($i+1);
	}
	return sum(@winnings);
}

class CamelCard {
	field $face :param :reader;

	ADJUST {
	}

	method value($use_jokers) {
		if ($face =~ m/\d/) {
			return $face + 0;
		}
		elsif ($face eq 'T') { return 10; }
		elsif ($face eq 'J') { return $use_jokers ? 1 : 11; }
		elsif ($face eq 'Q') { return 12; }
		elsif ($face eq 'K') { return 13; }
		elsif ($face eq 'A') { return 14; }
		die "Unknown face $face";
	}

	method compare($other_cc, $use_jokers) {
		return $self->value($use_jokers) <=> $other_cc->value($use_jokers);
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
}

class CamelCardHand {
	field $str :param :reader;
	field $cards :reader;
	field $bid :reader;

	ADJUST {
		my @parts = split(/ /, $str);

		my @faces = split(//, $parts[0]);
		my @c = map { CamelCard->new(face => $_) } @faces;
		$cards = \@c;

		$bid = $parts[1] + 0;
	}

	method compare($other, $use_jokers) {
		if ($self->type($use_jokers)->value() == $other->type($use_jokers)->value()) {
			# based on face value of first, second, third, fourth, fifth cards
			for my $i (0..4) {
				my $cmp = $self->cards->[$i]->value($use_jokers) <=> $other->cards->[$i]->value($use_jokers);
				return $cmp if $cmp != 0;
			}
		}
		return $self->type($use_jokers)->compare($other->type($use_jokers));
	}


	method type( $use_jokers ) {
		my @faces = map { $_->face() } @{$cards};
		my %hist = ();
		for my $face (@faces) {
			$hist{$face}++;
		}

		if ($use_jokers && exists($hist{'J'})) {
			my $j = $hist{'J'};
			delete $hist{'J'};
			my ($max_count, $face) = (0, "J");
			for my $key (keys %hist) {
				if ($hist{$key} > $max_count) {
					$max_count = $hist{$key};
					$face = $key;
				}
			}
			$hist{$face} += $j;
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


	method debug_str($use_jokers) {
		return $str . " (" . $bid . ") " . $self->type(0)->type() . " -> " . $self->type(1)->type();
	}
}
