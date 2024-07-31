<?php

declare(strict_types=1);
namespace sjb\aoc2023;

require_once "Geometry.php";

interface GridValue {
	public function getGlyph(): string;
}

class Grid2D {
	static private array $ADJACENCY_RULES = array('ROOK', 'QUEEN', 'BISHOP');
	
	static public function getAdjacencyOffsets(string $rule): array {
		$result = array();
		if (strtoupper($rule) == 'ROOK' || strtoupper($rule) == 'QUEEN') {
			array_push($result, Coord2D::getOffset('N'));
			array_push($result, Coord2D::getOffset('E'));
			array_push($result, Coord2D::getOffset('S'));
			array_push($result, Coord2D::getOffset('W'));
		}
		if (strtoupper($rule) == 'BISHOP' || strtoupper($rule) == 'QUEEN') {
			array_push($result, Coord2D::getOffset('NW'));
			array_push($result, Coord2D::getOffset('NE'));
			array_push($result, Coord2D::getOffset('SE'));
			array_push($result, Coord2D::getOffset('SW'));
		}
		return $result;
	}
	
	protected array $data;
	protected string $default;
	protected string $rule;
	protected ?Extent2D $ext;
	
	public function __construct(string $rule='ROOK', string $default='.') {
		$this->data = array();
		$this->default = $default;
		$this->rule = $rule;
		$this->ext = null;
	}

	public function __clone() {
		$cloned = new Grid2D($this->rule, $this->default);
		$cloned->data = $this->data;
		$cloned->ext = clone $this->ext;
		return $cloned;
	}
	
	public function load(array $rows) {
		for ($r = 0; $r < count($rows); $r++) {
			$width = strlen($rows[$r]);
			for ($c = 0; $c < $width; $c++) {
				$ch = substr($rows[$r], $c, 1);
				if ($ch != $this->default) {
					$this->setValue(new Coord2D($c, $r), $ch);
				}
			}
		}
	}
	
	public function getDefault() {
		return $this->default;
	}
	
	public function getRule() {
		return $this->rule;
	}
	
	public function getValue(Coord2D $c) {
		$key = $c->toString();
		if (array_key_exists($key, $this->data)) {
			return $this->data[$key];
		}
		return $this->default;
	}
	
	public function getStringValue(Coord2D $c): string {
		$value = $this->getValue($c);
		if (gettype($value) == "array" && count($value) > 0) {
			if (array_key_exists('glyph', $value)) {
				return $value['glyph'];
			}
			else {
				return strval($value[0]);
			}
		}
		elseif (gettype($value) == "object" && $value instanceof GridValue) {
			return $value->getGlyph();
		}
		return strval($value);
	}
	
	public function setValue(Coord2D $atCoord, $value): void {
		$key = $atCoord->toString();
		$this->data[$key] = $value;
		if (is_null($this->ext)) {
			$this->ext = new Extent2D($atCoord, $atCoord);
		}
		else {
			$this->ext = $this->ext->expandedToFit($atCoord);
		}
	}
	
	public function clear(Coord2D $atCoord, bool $resetExtent=false): void {
		$key = $atCoord->toString();
		unset($this->data[$key]);
		if ($resetExtent) {
			$this->ext = Extent2D::build($this->getCoords());
		}
	}
	
	public function getExtent(): ?Extent2D {
		if (is_null($this->ext)) { return null; }
		return clone $this->ext;
	}
	
	public function getCoords(): array {
		$keys = array_keys($this->data);
		$coords = array_map(fn($value): Coord2D => Coord2D::fromString($value), $keys);
		return $coords;
	}
	
	public function getCoordsWithValue($value): array {
		$keys = array_keys($this->data);
		$coords = array();
		foreach ($keys as $key) {
			if ($this->data[$key] == $value) {
				$coords[] = Coord2D::fromString($key);
			}
		}
		return $coords;
	}
	
	public function getHistogram(): array {
		$hist = array();
		if (empty($this->data)) { return $hist; }
		foreach ($this->ext->getAllCoords() as $c) {
			$val = $this->getStringValue($c);
			if (!array_key_exists($val, $hist)) { $hist[$val] = 0; }
			$hist[$val]++;
		}
		return $hist;
	}
	
	public function getOffsets(): array {
		return static::getAdjacencyOffsets($this->rule);
	}
	
	public function getNeighbors(Coord2D $c): array {
		$neighbors = array();
		foreach ($this->getOffsets() as $o) {
			$neighbors[] = $c->add($o);
		}
		return $neighbors;
	}
	
	public function print(array $markers=null, bool $invertY=false): void {
		echo $this->toString($markers, $invertY);
	}
	
	public function toString(array $markers=null, bool $invertY=false): string {
		$str = '';
		$ext = $this->getExtent();
		$yMin = $ext->yMin();
		$yMax = $ext->yMax();
		if ($invertY) {
			$temp = $yMin;
			$yMin = $yMax;
			$yMax = $temp;
		}
		foreach (range($yMin, $yMax) as $y) {
			$row = array();
			foreach (range($ext->xMin(), $ext->xMax()) as $x) {
				$c = new Coord2D($x, $y);
				$glyph = $this->getStringValue($c);
				if (!is_null($markers) && array_key_exists($c->toString(), $markers)) {
					$glyph = $markers[$c->toString()];
				}
				$row[] = $glyph;
			}
			$row[] = "\n";
			$str .= join(' ', $row);
		}
		return $str;
	}
}