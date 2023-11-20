<?php

declare(strict_types=1);
namespace sjb\aoc2023;

use PHPUnit\Framework\TestCase;
require 'src/lib/Util.php';

final class UtilTest extends TestCase
{
	private const INPUT_PATH = '../Input';
	private const INPUT_FILENAME = 'day00_test.txt';
	
	private string $input_file;
	
	protected function setUp(): void {
		$this->input_file = UtilTest::INPUT_PATH . '/' . UtilTest::INPUT_FILENAME;
	}
	
    // Sample test
    public function testPhpUnit(): void {
    	$this->assertTrue(1 == 1);
    	$this->assertSame('../Input/day00_test.txt', $this->input_file);
    }
    
    public function testReadInput(): void {
    	# Read input verbatim
    	$input = read_input($this->input_file);
    	#var_dump($input);
    	$this->assertEquals(count($input), 10);
    	$this->assertEquals($input[4], 'G1, L0');
    	
    	# Read input, ignoring empty lines
    	$input = read_input($this->input_file, true);
    	$this->assertEquals(count($input), 8);
    	$this->assertEquals($input[4], 'G1, L1');
    }
    
    public function testReadGroupedInput(): void {
    	# Reading groups
    	$input = read_grouped_input($this->input_file);
    	$this->assertEquals(count($input), 3);
    	$this->assertEquals($input[1][0], 'G1, L0');
    	
    	# Reading an indexed group
    	$group = read_grouped_input($this->input_file, 1);
    	$this->assertEquals(count($group), 2);
    	
    	# Reading an out of bounds index
    	$group = read_grouped_input($this->input_file, 10);
    	$this->assertEmpty($group);
    }
    
    protected function tearDown(): void {}
}