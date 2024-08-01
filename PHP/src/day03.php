<?php

namespace sjb\aoc2023;

require 'lib/Util.php';
require 'lib/Geometry.php';
require 'lib/Grid.php';

echo "Advent of Code 03, Day 03: Gear Ratios\n";

$INPUT_DIR = '../Input/';
// $INPUT_FILE = 'day03_test.txt';
$INPUT_FILE = 'day03_challenge.txt';
$INPUT_INDEX = 0;

$input = read_grouped_input($INPUT_DIR . $INPUT_FILE, $INPUT_INDEX);

$schematic = new Grid2D('QUEEN', '.');
$schematic->load($input);
// $schematic->print();


$result1 = solvePartOne($schematic);
echo "Part One: $result1\n";

//$result2 = solvePartTwo($input);
//echo "Part Two: $result2\n";


function solvePartOne(Grid2D $schematic):int {
	$num = '';
	$start = null;
	$numbers = [];
	$ext = $schematic->getExtent()->inset(-1);
	
	foreach ($ext->getAllCoords() as $coord) { // Is in "reading order"
		$val = $schematic->getValue($coord);
		if (is_numeric($val)) {
			if (is_null($start)) { $start = $coord; }
			$num .= $val;
		}
		else if (strlen($num) > 0) {
			$searchExt = new Extent2D($start, $coord->offset('<')); // Rewind to previous coord
			$symLocation = findAdjacentSymbol($searchExt, $schematic);
			if ($symLocation) {
				//$sym = $schematic->getValue($symLocation);
				array_push($numbers, intval($num));
			}
			$num = '';
			$start = null;
		}
	}
	
	$sum = array_reduce($numbers, fn($sum,$num) => $sum + $num, 0);
	return $sum;
}

function solvePartTwo(array $input):int  {
	return 0;
}

function findAdjacentSymbol(Extent2D $extent, Grid2D $schematic): ?Coord2D {
	$outset = $extent->inset(-1);
	foreach ($outset->getAllCoords() as $coord) {
		$val = $schematic->getValue($coord);
		if ($val != $schematic->getDefault() && !is_numeric($val)) {
			return $coord;
		}
	}
	return null;
}