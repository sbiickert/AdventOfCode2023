<?php

declare(strict_types=1);
namespace sjb\aoc2023;

use PHPUnit\Framework\TestCase;
require_once 'src/lib/Geometry.php';
require_once 'src/lib/Grid.php';


class Santa implements GridValue {
	public function getGlyph(): string {
		return 'S';
	}
}

final class GridTest extends TestCase
{
	protected function setUp(): void {
	}
	
    public function testGrid2D(): void {
    	$grid = new Grid2D();
    	$this->assertEquals($grid->getRule(), 'ROOK');
    	$this->assertEquals($grid->getDefault(), '.');
    	$this->assertNull($grid->getExtent());
    	
    	$grid->setValue(new Coord2D(1,1), 'A');
    	$grid->setValue(new Coord2D(2,2), 'B');
    	$grid->setValue(new Coord2D(4,4), 'D');
    	
    	$elf = array("glyph" => "E", "type" => "Elf", "HP" => 100);
    	$gob = array("G", "Goblin", 95);
    	$san = new Santa();
    	
    	$grid->setValue(new Coord2D(1,4), $elf);
    	$grid->setValue(new Coord2D(2,4), $gob);
    	$grid->setValue(new Coord2D(3,4), $san);
    	
    	$this->assertEquals($grid->getValue(new Coord2D(1,1)), 'A');
    	$this->assertEquals($grid->getValue(new Coord2D(2,2)), 'B');
    	$this->assertEquals($grid->getValue(new Coord2D(3,3)), $grid->getDefault());
    	$this->assertEquals($grid->getValue(new Coord2D(4,4)), 'D');
    	
    	$this->assertEquals($grid->getStringValue(new Coord2D(1,4)), 'E');
    	$this->assertEquals($grid->getStringValue(new Coord2D(2,4)), 'G');
    	$this->assertEquals($grid->getStringValue(new Coord2D(3,4)), 'S');
    	
    	$this->assertTrue($grid->getExtent()->equalTo(Extent2D::fromInts(1,1,4,4)));
    	
    	$coords = $grid->getCoords();
    	$this->assertEquals(count($coords), 6);
    	$matching = $grid->getCoordsWithValue('B');
    	$this->assertEquals(count($matching), 1);
    	$this->assertTrue($matching[0]->equalTo(new Coord2D(2,2)));
    	
    	$grid->setValue(new Coord2D(3,3), 'B');
    	$hist = $grid->getHistogram();
    	$this->assertTrue($hist['A'] == 1 && $hist['B'] == 2 && $hist['.'] == 9);
    	
    	$off = $grid->getOffsets();
    	$this->assertEquals(count($off), 4);
    	$bishopGrid = new Grid2D('BISHOP', '.');
    	$off = $bishopGrid->getOffsets();
    	$this->assertEquals(count($off), 4);
    	$queenGrid = new Grid2D('QUEEN', '.');
    	$off = $queenGrid->getOffsets();
    	$this->assertEquals(count($off), 8);
    	
    	$n = $grid->getNeighbors(new Coord2D(2,2));
    	$this->assertEquals(count($n), 4);
    	$this->assertTrue($n[0]->equalTo(new Coord2D(2,1)));
    	
    	$gridString = $grid->toString();
    	$this->assertEquals($gridString, "A . . . \n. B . . \n. . B . \nE G S D \n");
    	$gridString = $grid->toString(null, true); # invert y
    	$this->assertEquals($gridString, "E G S D \n. . B . \n. B . . \nA . . . \n");
		$markers = array((new Coord2D(4,1))->toString() => '*');
    	$gridString = $grid->toString($markers);
    	$this->assertEquals($gridString, "A . . * \n. B . . \n. . B . \nE G S D \n");
    	
    	$c2 = new Coord2D(2,2);
    	$c100 = new Coord2D(100,100);
    	$grid->clear($c2);
    	$this->assertEquals($grid->getValue($c2), '.');
    	$ext = $grid->getExtent();
    	$grid->setValue($c100, 'X');
    	$this->assertTrue($grid->getExtent()->equalTo(Extent2D::fromInts(1,1,100,100)));
    	$grid->clear($c100, true);
    	$this->assertTrue($grid->getExtent()->equalTo($ext));
    }
    
    public function testGridLoad(): void {
		$grid = new Grid2D(rule: 'ROOK', default: '.');
		$data = ['abcde', 'f.ghi', ' klmn'];
		$grid->load($data);
		//$grid->print();
		$ext = $grid->getExtent();
		$this->assertTrue($ext->equalTo(Extent2D::fromInts(0,0,4,2)));
		$this->assertTrue($grid->getValue(new Coord2D(3,0)) == 'd');
	}
    
    protected function tearDown(): void {}
}
