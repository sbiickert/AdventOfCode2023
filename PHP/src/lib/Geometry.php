<?php

declare(strict_types=1);
namespace sjb\aoc2023;

class Coord2D {
	static private array $OFFSET_DIRS = array();
	static private array $OFFSET_ALIASES = array();
	
	public static function __constructStatic() {
		# https://liamhammett.com/static-constructors-in-php-y0zPVbQl
		static::$OFFSET_DIRS = array(
					'N' 	=> new Coord2D( 0,-1),
					'NE' 	=> new Coord2D( 1,-1),
					'E' 	=> new Coord2D( 1, 0),
					'SE' 	=> new Coord2D( 1, 1),
					'S' 	=> new Coord2D( 0, 1),
					'SW' 	=> new Coord2D(-1, 1),
					'W' 	=> new Coord2D(-1, 0),
					'NW' 	=> new Coord2D(-1,-1));
		static::$OFFSET_ALIASES = array(
			'UP' => 'N', '^' => 'N',
			'DOWN' => 'S', 'v' => 'S',
			'LEFT' => 'W', '<' => 'W',
			'RIGHT' => 'E', '>' => 'E');
	}
	
	public static function getOffset(string $direction): Coord2D {
		$resolved = static::resolveOffsetAlias($direction);
		if (array_key_exists($resolved, static::$OFFSET_DIRS)) {
			return static::$OFFSET_DIRS[$resolved];
		}
		return static::origin();
	}
	
	public static function resolveOffsetAlias(string $direction): string {
		if (array_key_exists($direction, static::$OFFSET_ALIASES)) {
			return static::$OFFSET_ALIASES[$direction];
		}
		return $direction;
	}
	
	protected int $x;
	protected int $y;
	
	public static function fromString(string $xyString): Coord2D {
		preg_match('/\[(-?\d+),(-?\d+)\]/', $xyString, $matches);
		return new Coord2D(intval($matches[1]), intval($matches[2]));
	}
	
	public static function origin(): Coord2D {
		return new Coord2D(0,0);
	}
		
	function __construct(int $x, int $y) {
		$this->x = $x;
		$this->y = $y;
	}
	
	public function getX(): int { return $this->x; }
// 	public function setX(int $value): int {
// 		$this->x = $value;
// 		return $this->x;
// 	}

	public function getY(): int { return $this->y; }
// 	public function setY(int $value): int {
// 		$this->y = $value;
// 		return $this->y;
// 	}

	public function add(Coord2D $offset): Coord2D {
		return new Coord2D($this->x + $offset->x, $this->y + $offset->y);
	}
	
	public function offset(string $direction): Coord2D {
		return $this->add(Coord2D::getOffset($direction));
	}
	
	public function equalTo(Coord2D $other): bool {
		return ($this->x == $other->x && $this->y == $other->y);
	}
	
	public function deltaTo(Coord2D $other): Coord2D {
		$delta = new Coord2D($other->x - $this->x, $other->y - $this->y);
		return $delta;
	}
	
	public function manhattanDistanceTo(Coord2D $other): int {
		$delta = $this->deltaTo($other);
		return abs($delta->x) + abs($delta->y);
	}
	
	public function distanceTo(Coord2D $other): float {
		$delta = $this->deltaTo($other);
		return sqrt($delta->x * $delta->x + $delta->y * $delta->y);
	}
	
	public function clone(): Coord2D {
		return new Coord2D($this->x, $this->y);
	}
	
	public function toString(): string {
		return "[$this->x,$this->y]";
	}
}

Coord2D::__constructStatic();

class Position2D {
	static private array $TURN_LEFT = array('CCW', 'LEFT', 'L');
	static private array $TURN_RIGHT = array('CW', 'RIGHT', 'R');
	static private array $ORDERED_DIRS = array('N', 'E', 'S', 'W');

	protected Coord2D $location;
	protected string $direction;
	
	function __construct(Coord2D $location, string $direction) {
		$this->location = $location;
		$this->direction = Coord2D::resolveOffsetAlias($direction);
	}
	
	public function getLocation(): Coord2D {
		return $this->location;
	}
	
	public function getDirection(): string {
		return $this->direction;
	}
	
	public function getOffset(): Coord2D {
		return Coord2D::getOffset($this->direction);
	}
	
	public function turned(string $rotation): Position2D {
		$step = 0;
		if (in_array($rotation, static::$TURN_RIGHT)) { $step = 1; }
		elseif (in_array($rotation, static::$TURN_LEFT)) { $step = -1; }
		if ($step != 0) {
			$index = array_search($this->direction, static::$ORDERED_DIRS);
			if ($index === false) { return $this->clone(); }
			$index = trueMod(($index + $step), 4); // PHP mod returns negative numbers
		}
		return new Position2D($this->location->clone(), static::$ORDERED_DIRS[$index]);
	}
	
	public function movedForward(int $distance=1): Position2D {
		$newLocation = $this->location;
		$offset = $this->getOffset();
		foreach (range(1,$distance) as $i) {
			$newLocation = $newLocation->add($offset);
		}
		return new Position2D($newLocation, $this->direction);
	}
	
	public function equalTo(Position2D $other): bool {
		return ($this->location->equalTo($other->location) &&
				$this->direction == $other->direction);
	}
	
	public function clone(): Position2D {
		return new Position2D($this->location->clone(), $this->direction);
	}
	
	public function toString(): string {
		return '{' . $this->location->toString() . ' ' . $this->direction . '}';
	}
}

class Extent1D {
	protected int $min;
	protected int $max;
	
	function __construct(int $min, int $max) {
		$this->min = min($min, $max);
		$this->max = max($min, $max);
	}
	
	function getMin(): int { return $this->min; }

	function getMax(): int { return $this->max; }
	
	function equalTo(Extent1D $other): bool {
		return ($this->min == $other->min && $this->max == $other->max);
	}
	
	function getSize(): int {
		return ($this->max - $this->min) + 1;
	}
	
	function contains(Extent1D $other): bool {
		return $this->min <= $other->min && $this->max >= $other->max;
	}
	
	function overlaps(Extent1D $other): bool {
		$result = $this->intersect($other);
		return !(is_null($result));
	}
	
	function union(Extent1D $other): Extent1D {
		return new Extent1D(
			min($this->min, $other->min, $this->max, $other->max),
			max($this->min, $other->min, $this->max, $other->max));
	}
	
	function intersect(Extent1D $other): ?Extent1D {
		$bigmin = max($this->min, $other->min);
		$smallmax = min($this->max, $other->max);
		if ($bigmin <= $smallmax) {
			return new Extent1D($bigmin, $smallmax);
		}
		return null;
	}
	
	function containsValue(int $v): bool {
		return $this->min <= $v && $this->max >= $v;
	}

	function clone(): Extent1D {
		return new Extent1D($this->min, $this->max);
	}
		
	function toString(): string {
		return '{min: ' . $this->min . ', max: ' . $this->max . ']}';
	}
}

class Extent2D {
	protected Coord2D $min;
	protected Coord2D $max;
	
	static function build(array $coords): Extent2D {
		assert(count($coords) >= 2, 'Not enough points passed to Extent2D::build');
		$ext = new Extent2D($coords[0], $coords[1]);
		for ($i = 2; $i < count($coords); $i++) {
			$ext = $ext->expandedToFit($coords[$i]);
		}
		return $ext;
	}
	
	static function fromInts(int $xmin, int $ymin, int $xmax, int $ymax): Extent2D {
		return new Extent2D(new Coord2D($xmin, $ymin), new Coord2D($xmax, $ymax));
	}
		
	function __construct(Coord2D $a, Coord2D $b) {
		# Not going to trust inputs are min and max
		$xmin = min($a->getX(), $b->getX());
		$xmax = max($a->getX(), $b->getX());
		$ymin = min($a->getY(), $b->getY());
		$ymax = max($a->getY(), $b->getY());
		$this->min = new Coord2D($xmin, $ymin);
		$this->max = new Coord2D($xmax, $ymax);
	}
	
	function expandedToFit(Coord2D $c): Extent2D {
		$min = new Coord2D(min( $this->xMin(), $c->getX() ),
							min( $this->yMin(), $c->getY() ));
		$max = new Coord2D(max( $this->xMax(), $c->getX() ),
							max( $this->yMax(), $c->getY() ));
		return new Extent2D($min, $max);
	}
	
	function xMin(): int { return $this->min->getX(); }
	function yMin(): int { return $this->min->getY(); }
	function xMax(): int { return $this->max->getY(); }
	function yMax(): int { return $this->max->getY(); }
	
	function getMin(): Coord2D {	return $this->min->clone();	}
	function getMax(): Coord2D {	return $this->max->clone();	}
	function getNW(): Coord2D  {	return $this->getMin();	}
	function getSE(): Coord2D  {	return $this->getMax();	}
	function getNE(): Coord2D  {	return new Coord2D($this->xMax(), $this->yMin());	}
	function getSW(): Coord2D  {	return new Coord2D($this->xMin(), $this->yMax());	}
	
	function getWidth(): int {
		return $this->xMax() - $this->xMin() + 1;
	}
	
	function getHeight(): int {
		return $this->yMax() - $this->yMin() + 1;
	}
	
	function getArea(): int {
		return $this->getWidth() * $this->getHeight();
	}
	
	function getAllCoords(): array {
		$coords = array();
		foreach (range($this->xMin(), $this->xMax()) as $x) {
			foreach (range($this->yMin(), $this->yMax()) as $y) {
				array_push( $coords, new Coord2D($x, $y) );
			}
		}
		return $coords;
	}
	
	function contains(Coord2D $c): bool {
		return $this->min->getX() <= $c->getX() && $c->getX() <= $this->max->getX() &&
			$this->min->getY() <= $c->getY() && $c->getY() <= $this->max->getY();
	}
	
	function intersect(Extent2D $other): ?Extent2D {
		$common_min_x = max($this->min->getX(), $other->min->getX());
		$common_max_x = min($this->max->getX(), $other->max->getX());
		if ($common_max_x < $common_min_x) { return null; }
		$common_min_y = max($this->min->getY(), $other->min->getY());
		$common_max_y = min($this->max->getY(), $other->max->getY());
		if ($common_max_y < $common_min_y) { return null; }

		return new Extent2D(new Coord2D($common_min_x, $common_min_y),
							new Coord2D($common_max_x, $common_max_y));
	}
	
	function union(Extent2D $other): array {
		$results = array();
		$debug = false;
		if ($debug) {echo "Union of " . $this->toString() . " and " . $other->toString() . "\n";}
		
		if ($this->equalTo($other)) {
			array_push($results, $this->clone());
			return $results;
		}
		
		$int = $this->intersect($other);
		if (is_null($int)) {
			array_push($results, $this->clone());
			array_push($results, $other->clone());
			return $results;
		}
		
		if ($debug) {echo "Intersection: " . $int->toString() . "\n";}
		array_push($results, $int);
		foreach (array($this, $other) as $ext) {
			if ($ext->min->getX() < $int->min->getX()) {
				if ($ext->min->getY() < $int->min->getY()) {
					$result = new Extent2D($ext->getNW(), $int->getNW()->offset('NW'));
					if ($debug) {echo "NW: " . $result->toString() . "\n";}
					array_push($results, $result);
				}
				if ($ext->max->getY() > $int->max->getY()) {
					$result = new Extent2D($int->getSW()->offset('SW'), $ext->getSW());
					if ($debug) {echo "SW: " .$result->toString() . "\n";}
					array_push($results, $result);
				}
				#West
				$result =  new Extent2D(new Coord2D($ext->min->getX(), $int->min->getY()),
										new Coord2D($int->min->getX()-1, $int->max->getY()));
				if ($debug) {echo " W: " .$result->toString() . "\n";}
				array_push($results, $result);
			}
			if ($int->max->getX() < $ext->max->getX()) {
				if ($ext->min->getY() < $int->min->getY()) {
					$result = new Extent2D($ext->getNE(), $int->getNE()->offset('NE'));
					if ($debug) {echo "NE: " . $result->toString() . "\n";}
					array_push($results, $result);
				}
				if ($ext->max->getY() > $int->max->getY()) {
					$result = new Extent2D($int->getSE()->offset('SE'), $ext->getSE());
					if ($debug) {echo "SE: " . $result->toString() . "\n";}
					array_push($results, $result);
				}
				#East
				$result = new Extent2D(new Coord2D($int->max->getX()+1, $int->min->getY()),
										new Coord2D($ext->max->getX(), $int->max->getY()));
				if ($debug) {echo " E: " .$result->toString() . "\n";}
				array_push($results, $result);
			}
			if ($ext->min->getY() < $int->min->getY()) {
				#North
				$result = new Extent2D(new Coord2D($int->min->getX(), $int->min->getY()-1),
										new Coord2D($int->max->getX(), $ext->min->getY()));
				if ($debug) {echo " N: " . $result->toString() . "\n";}
				array_push($results, $result);
			}
			if ($int->max->getY() < $ext->max->getY()) {
				#South
				$result = new Extent2D(new Coord2D($int->min->getX(), $int->max->getY()+1),
										new Coord2D($int->max->getX(), $ext->max->getY()));
				if ($debug) {echo " S: " . $result->toString() . "\n";}
				array_push($results, $result);
			}
		}
		
		return $results;
	}
	
	function inset(int $amt): ?Extent2D {
		$xmin = $this->min->getX() + $amt;
		$xmax = $this->max->getX() - $amt;
		$ymin = $this->min->getY() + $amt;
		$ymax = $this->max->getY() - $amt;
		
		if ($xmin > $xmax || $ymin > $ymax) {
			return null;
		}
		return new Extent2D(new Coord2D($xmin, $ymin), new Coord2D($xmax, $ymax));
	}
	
	function equalTo(Extent2D $other): bool {
		return ($this->min->equalTo($other->min) && $this->max->equalTo($other->max));
	}

	function clone(): Extent2D {
		return new Extent2D($this->min->clone(), $this->max->clone());
	}
		
	function toString(): string {
		return '{min: ' . $this->min->toString() .
			 ', max: ' . $this->max->toString() . '}';
	}
}
