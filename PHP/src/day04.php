<?php

namespace sjb\aoc2023;

require 'lib/Util.php';
// require 'lib/Geometry.php';
// require 'lib/Grid.php';

echo "Advent of Code 04, Day 04: Scratchcards\n";

$INPUT_DIR = '../Input/';
// $INPUT_FILE = 'day04_test.txt';
$INPUT_FILE = 'day04_challenge.txt';
$INPUT_INDEX = 0;

$input = read_grouped_input($INPUT_DIR . $INPUT_FILE, $INPUT_INDEX);

$result1 = solvePartOne($input);
echo "Part One: The total number of points is $result1\n";

$result2 = solvePartTwo($input);
echo "Part Two: The number of scratchcards is $result2\n";



function solvePartOne(array $input):int {
	$card = new ScratchCard($input[0]);
	$cards = array_map(fn($line) => new ScratchCard($line), $input);
	$sum = array_reduce($cards, fn($sum, $card) => $card->getPoints() + $sum, 0);
	
	return $sum;
}

function solvePartTwo(array $input):int  {
	$card = new ScratchCard($input[0]);
	$cards = array_map(fn($line) => new ScratchCard($line), $input);
	$max = count($cards);
	$counts = array_fill(1, $max, 1);
	
	foreach ($cards as $card) {
		$n = $card->getNumberOfMatches();
		$multiplier = $counts[$card->getID()];
		for ($i = $card->getID()+1; $i < $card->getID()+$n+1 && $i <= $max; $i++) {
			$counts[$i] += $multiplier;
		}
	}

	$sum = array_reduce($counts, fn($sum, $i) => $sum + $i, 0);
	return $sum;
}


class ScratchCard {
	private int $id;
	private array $winningNumbers;
	private array $myNumbers;
	
	function __construct(string $definition) {
		preg_match("/Card +(\d+): +([\d ]+) \| +([\d ]+)/", $definition, $matches);
		$this->id = intval($matches[1]);
		$this->winningNumbers = array_map(fn($val) => intval($val), preg_split("/ +/", $matches[2]));
		$this->myNumbers = array_map(fn($val) => intval($val), preg_split("/ +/", $matches[3]));
	}
	
	public function getID(): int { return $this->id; }
	
	public function getNumberOfMatches(): int {
		$matchingNumbers = array_filter($this->myNumbers, fn($num) => in_array($num, $this->winningNumbers));
		return count($matchingNumbers);
	}
	
	public function getPoints():int {
		$nMatches = $this->getNumberOfMatches();
		if ($nMatches == 0) { return 0; }
		return pow(2, $nMatches - 1);
	}
}
