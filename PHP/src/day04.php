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

$cards = array_map(fn($line) => new ScratchCard($line), $input);

$result1 = solvePartOne($cards);
echo "Part One: The total number of points is $result1\n";

$result2 = solvePartTwo($cards);
echo "Part Two: The number of scratchcards is $result2\n";



function solvePartOne(array $cards):int {
	$sum = array_reduce($cards, fn($sum, $card) => $card->getPoints() + $sum, 0);
	return $sum;
}

function solvePartTwo(array $cards):int  {
	$max = count($cards);
	$counts = array_fill(1, $max, 1);
	
	foreach ($cards as $card) {
		$n = $card->getNumberOfMatches();
		$id = $card->getID();
		$multiplier = $counts[$id];
		for ($i = $id+1; $i < $id+$n+1 && $i <= $max; $i++) {
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
		return count(
			array_filter($this->myNumbers,
				fn($num) => in_array($num, $this->winningNumbers))
		);
	}
	
	public function getPoints():int {
		$nMatches = $this->getNumberOfMatches();
		if ($nMatches == 0) { return 0; }
		return pow(2, $nMatches - 1);
	}
}
