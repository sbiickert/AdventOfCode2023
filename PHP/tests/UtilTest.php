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
    	$input = read_input($this->input_file, remove_empty_lines: true);
    	$this->assertEquals(count($input), 8);
    	$this->assertEquals($input[4], 'G1, L1');
    }
    
    public function testReadGroupedInput(): void {
    	# Reading groups
    	$input = read_grouped_input($this->input_file);
    	$this->assertEquals(count($input), 3);
    	$this->assertEquals($input[1][0], 'G1, L0');
    	
    	# Reading an indexed group
    	$group = read_grouped_input($this->input_file, group_index: 1);
    	$this->assertEquals(count($group), 2);
    	
    	# Reading an out of bounds index
    	$group = read_grouped_input($this->input_file, group_index: 10);
    	$this->assertEmpty($group);
    }
    
    public function testApproxEqual(): void {
    	$f1 = 10.0;
    	$f2 = 9.999999;
    	$this->assertTrue(approxEqual($f1, $f2));
    	$f2 = 9.99;
    	$this->assertFalse(approxEqual($f1, $f2));
    	$this->assertTrue(approxEqual($f1, $f2, tolerance: 0.1));
    }
    
    public function testReduce(): void {
    	$fractions = [ [2,4], [2,6], [2,8], [3,13] ];
    	$reduced = [];
    	foreach ($fractions as $frac) {
    		$r = reduce( $frac[0], $frac[1] );
    		array_push($reduced, $r);
    	}
    	
    	$this->assertTrue( $reduced[0][0] == 1 && $reduced[0][1] == 2 );
    	$this->assertTrue( $reduced[1][0] == 1 && $reduced[1][1] == 3 );
    	$this->assertTrue( $reduced[2][0] == 1 && $reduced[2][1] == 4 );
    	$this->assertTrue( $reduced[3][0] == 3 && $reduced[3][1] == 13 );
    }
    
    public function testGCD(): void {
    	$g1 = gcd(2,4);
    	$this->assertTrue($g1 == 2);
    	$g2 = gcd(15,20);
    	$this->assertTrue($g2 == 5);
    	$g3 = gcd(13,20);
    	$this->assertTrue($g3 == 1);
    }
    
    public function testLCM(): void {
    	$l1 = lcm([2,3,4]);
    	$this->assertTrue($l1 == 12);
    	$l2 = lcm([3,4,13]);
    	$this->assertTrue($l2 == 156);
    }
    
    protected function tearDown(): void {}
}