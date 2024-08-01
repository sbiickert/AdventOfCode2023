<?php

namespace sjb\aoc2023;

require 'lib/Util.php';
// require 'lib/Geometry.php';
// require 'lib/Grid.php';

echo "Advent of Code 2023, Day 02: Cube Conundrum\n";

$INPUT_DIR = '../Input/';
// $INPUT_FILE = 'day02_test.txt';
$INPUT_FILE = 'day02_challenge.txt';
$INPUT_INDEX = 0;

$input = read_grouped_input($INPUT_DIR . $INPUT_FILE, $INPUT_INDEX);

$result1 = solvePartOne($input);
echo "Part One: the sum of the IDs is $result1\n";

$result2 = solvePartTwo($input);
echo "Part Two: the sum of the powers is $result2\n";


function solvePartOne(array $input):int {
	$games = array_map(fn($line): CubeGame => new CubeGame($line), $input);
	$games = array_filter($games, fn($game) => $game->isPossibleWith(red: 12, green: 13, blue: 14));
	$sum = array_reduce($games, fn($sum,$game) => $sum + $game->getID(), 0);
	
	return $sum;
}

function solvePartTwo(array $input):int  {
	$games = array_map(fn($line): CubeGame => new CubeGame($line), $input);
	$sum = array_reduce($games, fn($sum,$game) => $sum + $game->getPower(), 0);
	
	return $sum;
}

class CubeGame {
	protected int $id;
	protected array $draws;
	
	function __construct(string $definition) {
		$parts = explode(': ', $definition);
		preg_match('/Game (\\d+)/', $parts[0], $matches);
		$this->id = intval($matches[1]);
		$drawDefns = explode('; ', $parts[1]);
		$this->draws = array_map(fn($dd): CubeGameDraw => new CubeGameDraw($dd), $drawDefns);
	}
	
	function getID(): int {
		return $this->id;
	}
	
	function isPossibleWith(int $red, int $green, int $blue): bool {
		$isPossible = true;
		foreach ($this->draws as $draw) {
			$isPossible = $isPossible && $draw->isPossibleWith($red, $green, $blue);
		}
		return $isPossible;
	}
	
	function getPower():int {
		$r = max(array_map(fn($draw) => $draw->getRed(), $this->draws));
		$g = max(array_map(fn($draw) => $draw->getGreen(), $this->draws));
		$b = max(array_map(fn($draw) => $draw->getBlue(), $this->draws));

		return $r * $g * $b;
	}
}

class CubeGameDraw {
	protected int $red = 0;
	protected int $green = 0;
	protected int $blue = 0;
	
	function __construct($definition) {
		preg_match('/(\\d+) red/', $definition, $matches);
		if ($matches) { $this->red = intval($matches[1]); }
		preg_match('/(\\d+) green/', $definition, $matches);
		if ($matches) { $this->green = intval($matches[1]); }
		preg_match('/(\\d+) blue/', $definition, $matches);
		if ($matches) { $this->blue = intval($matches[1]); }
	}
	
	function isPossibleWith(int $red, int $green, int $blue): bool {
		return $this->red <= $red && $this->green <= $green && $this->blue <= $blue;
	}
	
	function getRed():int { return $this->red; }
	function getGreen():int { return $this->green; }
	function getBlue():int { return $this->blue; }
}