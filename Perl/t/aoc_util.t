use Modern::Perl 2023;
use Test::Simple tests => 20;

use AOC::Util;

my $INPUT_PATH = '../Input';
my $INPUT_FILE = 'day00_test.txt';

say "Perl version : ".$];

test_read_input("$INPUT_PATH/$INPUT_FILE");
test_read_grouped_input("$INPUT_PATH/$INPUT_FILE");
test_approx_equal();
test_reduce();
test_gcd();
test_lcm();

sub test_read_input {
	say 'Testing reading input';
	my $input_file = shift;
	my @input = read_input($input_file);
	ok(scalar(@input) == 10, "Right number of lines in file");
	ok($input[4] eq "G1, L0", "Correct value at line 4");

	say 'Testing reading input, ignoring empty lines';
	@input = read_input($input_file, 1);
	ok(scalar(@input) == 8, "Right number of lines in file, ignoring empty");
	ok($input[4] eq "G1, L1", "Correct value at line 4");
}

sub test_read_grouped_input {
	say 'Testing reading grouped input';
	my $input_file = shift;
	my @input = read_grouped_input($input_file);
	ok(scalar(@input) == 3, "Right number of groups");
	ok($input[1][0] eq "G1, L0", "Correct value at first line of second group.");

	say 'Testing just reading group 1';
	my @group = read_grouped_input($input_file, 1);
	ok(scalar(@group) == 2, "Right number of lines in group 1");

	say 'Testing just reading a group index out of range (10)';
	@group = read_grouped_input($input_file, 10);
	ok(!@group, "Out of range group was empty.");
}

sub test_approx_equal {
	say 'Testing approximate equality';
	my $f1 = 10.0;
	my $f2 = 11.0 - 1.0;

	ok(approx_equal($f1, $f2), "Floats were equal with default threshold.");
	ok(approx_equal($f1, $f2, 0.0000001), "Floats were equal with user threshold.");

	my $f3 = 10.01;
	ok(!approx_equal($f1, $f3), "Floats were not equal.");
}

sub test_reduce() {
	say 'Testing fraction reduction';
	my @fractions = ([2, 4], [2, 6], [2, 8], [3,13]);
	my @reduced = ();
	foreach my $frac (@fractions) {
		my $r = reduce($frac);
		push @reduced, $r;
	}

	ok($reduced[0][0] == 1 && $reduced[0][1] == 2, "Reduction of 2/4.");
	ok($reduced[1][0] == 1 && $reduced[1][1] == 3, "Reduction of 2/6.");
	ok($reduced[2][0] == 1 && $reduced[2][1] == 4, "Reduction of 2/8.");
	ok($reduced[3][0] == 3 && $reduced[3][1] == 13, "Reduction of 3/13.");
 }

 sub test_gcd() {
	say 'Testing GCD';
	ok(gcd(2,4) == 2, 'GCD of 2 and 4');
	ok(gcd(15,20) == 5, 'GCD of 15 and 20');
	ok(gcd(13,20) == 1, 'GCD of 13 and 20');
 }

 sub test_lcm() {
	say 'Testing LCM';
	ok(lcm(2,3,4) == 12, 'LCM of 2, 3, 4');
	ok(lcm(3,4,13) == 156, 'LCM of 3, 4, 13');
 }