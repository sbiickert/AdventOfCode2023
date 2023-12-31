<?php

declare(strict_types=1);
namespace sjb\aoc2023;

function read_input(string $input_file, bool $remove_empty_lines = false): array {
	$content = array();
	
	$input = fopen($input_file, 'r');
	if ($input) {
		while (($line = fgets($input)) !== false) {
			$line = rtrim($line);
			if (strlen($line) == 0 && $remove_empty_lines) {}
			else {
				array_push($content, $line);
			}
		}

		fclose($input);
	}
	
	return $content;
}

function read_grouped_input(string $input_file, int $group_index = -1): array {
	$lines = read_input($input_file, false);
	
	$groups = array();
	$this_group = array();
	
	foreach ($lines as $line) {
		if (strlen($line) == 0) {
			if (count($this_group) > 0) {
				array_push($groups, $this_group);
			}
			$this_group = array();
		}
		else {
			array_push($this_group, $line);
		}
	}
	
	if (count($this_group) > 0) {
		array_push($groups, $this_group);
	}
	
	if ($group_index >= 0) {
		if ($group_index < count($groups)) {
			return $groups[$group_index];
		}
		return array();
	}
	
	return $groups;
}

function approxEqual(float $f1, float $f2, float $tolerance=0.0001): bool {
	return (abs($f1-$f2) < $tolerance);
}

function trueMod(int $num, int $mod): int {
	return ($mod + ($num % $mod)) % $mod;
}