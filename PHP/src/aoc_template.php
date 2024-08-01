<?php

namespace sjb\aoc2023;

require 'lib/Util.php';
// require 'lib/Geometry.php';
// require 'lib/Grid.php';

echo "Advent of Code <##>, Day <##>: <##>\n";

$INPUT_DIR = '../Input/';
$INPUT_FILE = 'day<##>_test.txt';
//$INPUT_FILE = 'day<##>_challenge.txt';
$INPUT_INDEX = 0;

$input = read_grouped_input($INPUT_DIR . $INPUT_FILE, $INPUT_INDEX);

$result1 = solvePartOne($input);
echo "Part One: $result1\n";

//$result2 = solvePartTwo($input);
//echo "Part Two: $result2\n";


function solvePartOne(array $input):int {
	return 0;
}

function solvePartTwo(array $input):int  {
	return 0;
}
