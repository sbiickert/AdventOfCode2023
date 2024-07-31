<?php

declare(strict_types=1);
namespace sjb\aoc2023;

use PHPUnit\Framework\TestCase;
require 'src/lib/Geometry.php';

final class GeometryTest extends TestCase
{
	protected function setUp(): void {

	}
	
	public function testCoord2DConstruction(): void {
		$coord = new Coord2D(x:2, y:3);
		$this->assertEquals($coord->getX(), 2);
		$this->assertEquals($coord->getY(), 3);
		
		$str = $coord->toString();
		$this->assertEquals($str, '[2,3]');
		
		$rehydrated = Coord2D::fromString($str);
		$this->assertTrue($coord->equalTo($rehydrated));
		
		$cloned = clone $coord;
		$this->assertTrue($coord->equalTo($cloned));
	}
	
	public function testCoord2DRelations(): void {
		$coord1 = new Coord2D(2,3);
		$coord2 = new Coord2D(2,3);
		$this->assertTrue($coord1->equalTo($coord2));
		
		$coord2 = new Coord2D(4,6);
		$this->assertFalse($coord1->equalTo($coord2));
		
		$delta = $coord1->deltaTo($coord2);
    	$this->assertTrue($delta->getX() == 2 && $delta->getY() == 3);
    	
    	$added = $coord1->add(Coord2D::getOffset('NE'));
    	$this->assertTrue($added->getX() == 3 && $added->getY() == 2);
	}
	
	public function testCoord2DDistance(): void {
		$coord1 = new Coord2D(10,30);
		$coord2 = new Coord2D(5,20);
		
		$dist = $coord1->distanceTo($coord2);
		$this->assertTrue(approxEqual($dist, 11.1803398874989));
		
		$md = $coord1->manhattanDistanceTo($coord2);
		$this->assertEquals($md, 15);
	}
	
    public function testCoord2DGetOffset(): void {
    	$north = Coord2D::getOffset('N');
    	$this->assertNotEmpty($north);
    	$this->assertTrue($north->getX() == 0 && $north->getY() == -1);
    	
    	$west = Coord2D::getOffset('<');
    	$this->assertNotEmpty($west);
    	$this->assertTrue($west->getX() == -1 && $west->getY() == 0);
    	
    	$invalid = Coord2D::getOffset('X');
    	$this->assertNotEmpty($invalid);
    	$this->assertTrue($invalid->getX() == 0 && $invalid->getY() == 0);
    	
    	$ne = Coord2D::origin()->offset('NE');
    	$this->assertTrue($ne->getX() == 1 && $ne->getY() == -1);
    }
    
    public function testPosition2DConstruction(): void {
    	$pos1 = new Position2D( Coord2D::origin(), 'E' );
    	$this->assertTrue($pos1->getLocation()->equalTo( new Coord2D(0,0)));
    	$this->assertEquals($pos1->getDirection(), 'E');
    }
    
    public function testPosition2DTurning(): void {
    	$pos1 = new Position2D( new Coord2D(5,5), '<' );
    	$this->assertEquals($pos1->getDirection(), 'W');
    	$turned = $pos1->turned('CW');
    	$this->assertEquals($turned->getDirection(), 'N');
    	$turned = $pos1->turned('CCW');
    	$this->assertEquals($turned->getDirection(), 'S');
    	
    	foreach (range(0,4) as $i) {
    		$turned = $turned->turned('CCW');
    	}
    	$this->assertEquals($turned->getDirection(), 'E');
    }
    
    public function testPosition2DMoving(): void {
    	$pos1 = new Position2D( new Coord2D(5,5), '<' );
		$moved = $pos1->movedForward();
		$this->assertTrue($moved->getLocation()->equalTo(new Coord2D(4,5)));  
		$moved = $pos1->movedForward(10);
		$this->assertTrue($moved->getLocation()->equalTo(new Coord2D(-5,5)));
		
		$posNoDirection = new Position2D(Coord2D::origin(), '?');
		$stationary = $posNoDirection->movedForward();
		$this->assertTrue($stationary->getLocation()->equalTo(Coord2D::origin()));  
    }
    
    public function testExtent1DConstruction(): void {
    	$ext = new Extent1D(1,9);
    	$this->assertEquals($ext->getMin(), 1);
    	$this->assertEquals($ext->getMax(), 9);
    	
    	$ext = new Extent1D(9,1);
    	$this->assertEquals($ext->getMin(), 1);
    	$this->assertEquals($ext->getMax(), 9);
    	
    	$cloned = clone $ext;
    	$this->assertEquals($cloned->getMin(), 1);
    	$this->assertEquals($cloned->getMax(), 9);
    	
    	$this->assertEquals($ext->getSize(), 9);
    }
    
    public function testExtent1DContainment(): void {
    	$ext = new Extent1D(1,9);
    	$this->assertFalse($ext->containsValue(0));
    	$this->assertTrue($ext->containsValue(1));
    	$this->assertTrue($ext->containsValue(4));
    	$this->assertTrue($ext->containsValue(9));
    	$this->assertFalse($ext->containsValue(10));
    	
    	$other = new Extent1D(0,1);
    	$this->assertFalse($ext->contains($other));
    	$other = new Extent1D(1,3);
    	$this->assertTrue($ext->contains($other));
    	$other = new Extent1D(10,11);
    	$this->assertFalse($ext->contains($other));
    }
    
    public function testExtent1DRelational(): void {
    	$ext = new Extent1D(1,9);
    	$other = new Extent1D(1,9);
    	$this->assertTrue($ext->equalTo($other));
    	$other = new Extent1D(2,8);
    	$this->assertFalse($ext->equalTo($other));
    	
    	$this->assertTrue($ext->union($other)->equalTo($ext));
    	$this->assertTrue($ext->intersect($other)->equalTo($other));

    	$other = new Extent1D(-1,0);
    	$this->assertTrue($ext->union($other)->equalTo(new Extent1D(-1,9)));
    	$this->assertNull($ext->intersect($other));
    	$this->assertFalse($ext->overlaps($other));
    	
    	$other = new Extent1D(-4,10);
    	$this->assertTrue($ext->union($other)->equalTo(new Extent1D(-4,10)));
    	$this->assertTrue($ext->intersect($other)->equalTo($ext));
    	$this->assertTrue($ext->overlaps($other));
    	
    	$other = new Extent1D(4,10);
    	$this->assertTrue($ext->union($other)->equalTo(new Extent1D(1,10)));
    	$this->assertTrue($ext->intersect($other)->equalTo(new Extent1D(4,9)));
    	$this->assertTrue($ext->overlaps($other));
    }
    
    public function testExtent2DCreation(): void {
    	$c = array(new Coord2D(-1,1),
    				new Coord2D(2,8),
    				new Coord2D(3,3),
    				new Coord2D(4,4));
    	
    	$ext = new Extent2D(new Coord2D(-1,1), new Coord2D(2,8));
    	$this->assertTrue($ext->getMin()->getX() == -1);
    	$this->assertTrue($ext->getMin()->getY() ==  1);
    	$this->assertTrue($ext->getMax()->getX() ==  2);
    	$this->assertTrue($ext->getMax()->getY() ==  8);
    	
    	$ext = Extent2D::build(array(
    				new Coord2D(-1,1),
    				new Coord2D(3,3),
    				new Coord2D(4,4)));
    	$this->assertTrue($ext->getMin()->getX() == -1);
    	$this->assertTrue($ext->getMin()->getY() ==  1);
    	$this->assertTrue($ext->getMax()->getX() ==  4);
    	$this->assertTrue($ext->getMax()->getY() ==  4);
    	
    	$cloned = clone $ext;
    	$this->assertTrue($cloned->getMin()->getX() == -1);
    	$this->assertTrue($cloned->getMin()->getY() ==  1);
    	$this->assertTrue($cloned->getMax()->getX() ==  4);
    	$this->assertTrue($cloned->getMax()->getY() ==  4);
    	
    	$this->assertTrue($ext->getWidth() == 6);
    	$this->assertTrue($ext->getHeight() == 4);
    	$this->assertTrue($ext->getArea() == 24);
    	
    	$ext = Extent2D::fromInts(1,2,3,4);
    	$this->assertTrue($ext->getMin()->getX() == 1);
    	$this->assertTrue($ext->getMin()->getY() == 2);
    	$this->assertTrue($ext->getMax()->getX() == 3);
    	$this->assertTrue($ext->getMax()->getY() == 4);
    }
    
    public function testExtent2DRelations(): void {
    	$ext1 = new Extent2D(new Coord2D(-1,1), new Coord2D(2,8));
    	$ext2 = Extent2D::build(array(new Coord2D(-1,1), new Coord2D(2,8)));
    	$ext3 = new Extent2D(new Coord2D(1,1), new Coord2D(4,4));
    	$this->assertTrue($ext1->equalTo($ext2));
    	$this->assertFalse($ext1->equalTo($ext3));
    	
    	$this->assertTrue($ext1->contains(new Coord2D(0,5)));
    	$this->assertFalse($ext1->contains(new Coord2D(-1,-1)));
    	$this->assertFalse($ext1->contains(new Coord2D(10,5)));
    	
    	$ins = $ext1->inset(1);
    	$this->assertNotNull($ins);
    	$this->assertTrue($ins->getMin()->equalTo(new Coord2D(0, 2)));
    	$this->assertTrue($ins->getMax()->equalTo(new Coord2D(1, 7)));
    	$ins = $ext1->inset(3);
    	$this->assertNull($ins);
    	
    	$ext = Extent2D::fromInts(1,1,10,10);
    	
    	$int = $ext->intersect(Extent2D::fromInts(5,5,12,12));
    	$this->assertTrue($int->equalTo(Extent2D::fromInts(5,5,10,10)));
    	$int = $ext->intersect(Extent2D::fromInts(5,5,7,7));
    	$this->assertTrue($int->equalTo(Extent2D::fromInts(5,5,7,7)));
    	$int = $ext->intersect(Extent2D::fromInts(1,1,12,2));
    	$this->assertTrue($int->equalTo(Extent2D::fromInts(1,1,10,2)));
    	$int = $ext->intersect(Extent2D::fromInts(11,11,12,12));
    	$this->assertNull($int);
    	$int = $ext->intersect(Extent2D::fromInts(1,10,10,20));
    	$this->assertTrue($int->equalTo(Extent2D::fromInts(1,10,10,10)));
    	
    	$products = $ext->union(Extent2D::fromInts(5,5,12,12));
    	$expected = array(Extent2D::fromInts(5,5,10,10),
							Extent2D::fromInts(1,1,4,4),
							Extent2D::fromInts(1,5,4,10),
							Extent2D::fromInts(5,1,10,4),
							Extent2D::fromInts(11,11,12,12),
							Extent2D::fromInts(11,5,12,10),
							Extent2D::fromInts(5,11,10,12));
		$this->assertTrue($this->verifyExtentUnionResults($products, $expected));
    	$products = $ext->union(Extent2D::fromInts(5,5,7,7));
    	$expected = array(Extent2D::fromInts(5,5,7,7),
							Extent2D::fromInts(1,1,4,4),
							Extent2D::fromInts(1,8,4,10),
							Extent2D::fromInts(1,5,4,7),
							Extent2D::fromInts(8,1,10,4),
							Extent2D::fromInts(8,8,10,10),
							Extent2D::fromInts(8,5,10,7),
							Extent2D::fromInts(5,1,7,4),
							Extent2D::fromInts(5,8,7,10));
		$this->assertTrue($this->verifyExtentUnionResults($products, $expected));
    	$products = $ext->union(Extent2D::fromInts(1,1,12,2));
    	$expected = array(Extent2D::fromInts(1,1,10,2),
							Extent2D::fromInts(1,3,10,10),
							Extent2D::fromInts(11,1,12,2));
		$this->assertTrue($this->verifyExtentUnionResults($products, $expected));
    	$products = $ext->union(Extent2D::fromInts(11,11,12,12));
    	$expected = array(Extent2D::fromInts(1,1,10,10),
							Extent2D::fromInts(11,11,12,12));
		$this->assertTrue($this->verifyExtentUnionResults($products, $expected));
    	$products = $ext->union(Extent2D::fromInts(1,10,10,20));
    	$expected = array(Extent2D::fromInts(1,10,10,10),
							Extent2D::fromInts(1,1,10,9),
							Extent2D::fromInts(1,11,10,20));
		$this->assertTrue($this->verifyExtentUnionResults($products, $expected));
    }
    
    private function verifyExtentUnionResults(array $actual, array $expected): bool {
    	//var_dump($actual);
    	//var_dump($expected);
    	if (count($actual) != count($expected)) {
    		echo "wrong count\n";
    		return false;
    	}
    	foreach (range(0, count($actual)-1) as $i) {
    		if (!$actual[$i]->equalTo($expected[$i])) {
    			return false;
    		}
    	}
    	return true;
    }
    
    protected function tearDown(): void {}
}