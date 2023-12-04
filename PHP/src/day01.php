<?php

namespace sjb\aoc2023;

require 'lib/Util.php';

echo "Advent of Code 2023, Day 1: Trebuchet?!\n";

$INPUT_DIR = '../Input/';

//$INPUT_FILE = 'day01_test.txt';
$INPUT_FILE = 'day01_challenge.txt';
$INPUT_INDEX = 0;

$input = read_grouped_input($INPUT_DIR . $INPUT_FILE, $INPUT_INDEX);

$LOOKUP = array("one" => "1", "two" => "2", "three" => "3",
				"four" => "4", "five" => "5", "six" => "6",
				"seven" => "7", "eight" => "8", "nine" => "9");

$sum_calibration_1 = solvePartOne($input);
echo "Part One: The calibration is $sum_calibration_1\n";

$sum_calibration_2 = solvePartTwo($input);
echo "Part Two: The calibration is $sum_calibration_2\n";

function solvePartOne(array $lines): int {
	$sum = 0;
	$reStart = "/^[^\d]*(\d)/";
	$reEnd = "/(\d)[^\d]*$/";
	
	foreach ($lines as $line) {
		preg_match($reStart, $line, $mStart);
		preg_match($reEnd, $line, $mEnd);
		$twoDigitString = $mStart[1] . $mEnd[1];
		$sum += intval($twoDigitString);
	}
		
	return $sum;
}

function solvePartTwo(array $lines): int {
	$sum = 0;
    $numberPat = "(\d|one|two|three|four|five|six|seven|eight|nine)";
	$reStart = "/^($numberPat)/";
	$reEnd = "/($numberPat)$/";
	
	foreach ($lines as $line) {
		$firstDigit = "";
		$lastDigit = "";
		
		while ($firstDigit == "") {
			if (preg_match($reStart, $line, $mStart)) {
				$firstDigit = digitFromMatch($mStart[1]);
			}
			else {
				$line = substr($line, 1);
			}
		}
		while ($lastDigit == "") {
			if (preg_match($reEnd, $line, $mEnd)) {
				$lastDigit = digitFromMatch($mEnd[1]);
			}
			else {
				$line = substr($line, 0, strlen($line)-1);
			}
		}
		$twoDigitString = $firstDigit . $lastDigit;
		$sum += intval($twoDigitString);
	}
		
	return $sum;
}

function digitFromMatch(string $matchStr): string {
	if (preg_match("/\d/", $matchStr)) { return $matchStr; }
	global $LOOKUP;
	return $LOOKUP[$matchStr];
}