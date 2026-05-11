#!/usr/bin/env perl
use v5.42;
# use feature 'class';
# no warnings qw( experimental::class );

our $directory;
BEGIN { use Cwd; $directory = cwd; }
use lib $directory . '/lib';

use feature 'signatures';
use Data::Printer;
use List::Util 'all';

use AOC::Util;

my $DAY = sprintf("%02d", 20);
my $INPUT = $ARGV[0];
my $INPUT_FILE = 'day' . $DAY . '_' . $INPUT . '.txt';

my @input = read_grouped_input("../Input/$INPUT_FILE", 0);

say "Advent of Code 2023, Day 20: Pulse Propagation";

my %modules = parse_modules(@input);
my @queue = ();
my $L_pulse_count = 0;
my $H_pulse_count = 0;

solve_part_one();
solve_part_two();

exit( 0 );

sub solve_part_one(@input) {
	my $button = $modules{'button'};

	for my $i (1..1000) {
		for my $out (@{$button->{'out'}}) {
			pulse_send($button->{'name'}, $out, 'L');
		}
		process_queue();
	}
	say "Part One: $H_pulse_count * $L_pulse_count is " . $H_pulse_count * $L_pulse_count;
}

sub pulse_send($from, $to, $type) {
# 	say "$from -$type-> $to";
	my %msg = ('from' => $from, 'to' => $to, 'type' => $type);
	push(@queue, \%msg);
	$H_pulse_count++ if $type eq 'H';
	$L_pulse_count++ if $type eq 'L';
}

sub process_queue() {
	while (scalar @queue > 0) {
		my $msg = shift(@queue);
		my $f = $msg->{'from'};
		my $to = $modules{$msg->{'to'}};
		if		($to->{'name'} eq 'broadcaster') {	broadcast($f, $to, $msg->{'type'})	}
		elsif	($to->{'kind'} eq '&')			 {	conjoin($f, $to, $msg->{'type'})	}
		elsif	($to->{'kind'} eq '%')			 {	flipflop($f, $to, $msg->{'type'})	}
		elsif	($to->{'kind'} eq '>')			 {	output($f, $to, $msg->{'type'})	}
	}
}

sub broadcast($from, $module, $type) {
	for my $out (@{$module->{'out'}}) {
		pulse_send($module->{'name'}, $out, $type);
	}
}

sub conjoin($from, $module, $type) {
	$module->{'in'}{$from} = $type;
	my $all_high = all {$_ eq 'H'} (values %{$module->{'in'}});
	my $send_pulse = $all_high ? 'L' : 'H';
	for my $out (@{$module->{'out'}}) {
		pulse_send($module->{'name'}, $out, $send_pulse);
	}
}

sub flipflop($from, $module, $type) {
	return if $type eq 'H';
	my $send_pulse = $module->{'on'} ? 'L' : 'H';
	for my $out (@{$module->{'out'}}) {
		pulse_send($module->{'name'}, $out, $send_pulse);
	}
	$module->{'on'} = !$module->{'on'};
}

sub output($from, $module, $type) {
}

sub solve_part_two(@input) {
	# gf is the conjunction module sending to rx.
	# Have determined that there are four conjuction modules (kr,kf,qk,zs)
	# that are sending pulses to gf
	# The are sending .high cyclically. kr=3761, kf=3767, qk=4001, zs=4091
	my $num_presses = lcm( 3761, 3767, 4001, 4091 );

	say "Part Two: the number of presses until a low pulse goes to rx is $num_presses.";
}

sub parse_modules(@input) {
	my %modules = ();
	my %out_names = ();

	for my $line (@input) {
		my %defn = parse_line($line);
		$modules{$defn{'name'}} = \%defn;
		for my $out_name (@{$defn{'out'}}) {	$out_names{$out_name} = 1;	}
	}

	my %button = ('kind' => '+', 'name' => 'button', 'out' => ['broadcaster']);
	$modules{'button'} = \%button;

	for my $out_name (keys %out_names) {
		if (!defined $modules{$out_name}) {
			my %inputs = ();
			my %out = ('kind' => '>', 'name' => $out_name, 'in' => \%inputs, 'out' => []);
			$modules{$out_name} = \%out;
		}
	}

	for my $module (values %modules) {
		for my $out_name (@{$module->{'out'}}) {
			$modules{$out_name}->{'in'}{$module->{'name'}} = 'L';
		}
	}
	return %modules;
}

sub parse_line($line) {
	$line =~ m/([\%\&]?)(\w+) -> (.+)/;
	my @outputs = split(/, /, $3);
	my %inputs = ();
	my %defn = ('kind' => $1, 'name' => $2, 'in' => \%inputs, 'out' => \@outputs, 'on' => 0);
	return %defn;
}
