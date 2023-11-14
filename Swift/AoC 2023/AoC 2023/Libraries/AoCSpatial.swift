//
//  AoCSpatial.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-04-27.
//

import Foundation

enum AoCAdjacencyRule {
	case rook
	case bishop
	case queen
}

var _coordOffsets = Dictionary<AoCAdjacencyRule, [AoCCoord2D]>()

struct AoCCoord2D: Hashable {
	let x: Int
	let y: Int
	
	static var zero: AoCCoord2D {
		return AoCCoord2D(x: 0, y: 0)
	}

	static func +(left: AoCCoord2D, right: AoCCoord2D) -> AoCCoord2D {
		return AoCCoord2D(x: left.x + right.x, y: left.y + right.y)
	}
	
	static func -(left: AoCCoord2D, right: AoCCoord2D) -> AoCCoord2D {
		return AoCCoord2D(x: left.x - right.x, y: left.y - right.y)
	}
	
	static func readingOrderSort(c0: AoCCoord2D, c1: AoCCoord2D) -> Bool {
		if c0.y == c1.y {
			return c0.x < c1.x
		}
		return c0.y < c1.y
	}
	
	func distance(to other: AoCCoord2D) -> Double {
		let delta = self - other
		return sqrt(Double(delta.x * delta.x + delta.y * delta.y))
	}
	
	func manhattanDistance(to other: AoCCoord2D) -> Int {
		return abs(self.x - other.x) + abs(self.y - other.y)
	}
	
	func isAdjacent(to other: AoCCoord2D, rule: AoCAdjacencyRule = .rook) -> Bool {
		switch rule {
		case .rook:
			return self.manhattanDistance(to: other) == 1
		case .bishop:
			return abs(x - other.x) == 1 && abs(y - other.y) == 1
		case .queen:
			return (self.manhattanDistance(to: other) == 1) || (abs(x - other.x) == 1 && abs(y - other.y) == 1)
		}
	}
	
	func getAdjacentCoords(rule: AoCAdjacencyRule = .rook) -> [AoCCoord2D] {
		var result = [AoCCoord2D]()
		for offset in AoCCoord2D.getAdjacentOffsets(rule: rule) {
			result.append(self + offset)
		}
		return result
	}
	
	static func getAdjacentOffsets(rule: AoCAdjacencyRule = .rook) -> [AoCCoord2D] {
		if _coordOffsets.keys.contains(rule) {
			return _coordOffsets[rule]!
		}
		
		var offsets: [AoCCoord2D]
		
		switch rule {
		case .rook:
			offsets = [AoCCoord2D(x: -1, y:  0), AoCCoord2D(x:  1, y:  0),
					   AoCCoord2D(x:  0, y: -1), AoCCoord2D(x:  0, y:  1)]
		case .bishop:
			offsets = [AoCCoord2D(x: -1, y: -1), AoCCoord2D(x:  1, y:  1),
					   AoCCoord2D(x:  1, y: -1), AoCCoord2D(x: -1, y:  1)]
		case .queen:
			offsets = [AoCCoord2D(x: -1, y:  0), AoCCoord2D(x:  1, y:  0),
					   AoCCoord2D(x:  0, y: -1), AoCCoord2D(x:  0, y:  1),
					   AoCCoord2D(x: -1, y: -1), AoCCoord2D(x:  1, y:  1),
					   AoCCoord2D(x:  1, y: -1), AoCCoord2D(x: -1, y:  1)]
		}
		
		_coordOffsets[rule] = offsets
		return offsets
	}
	
	var description: String {
		return "[x: \(x), y: \(y)]"
	}
}

enum AoCDirection: String, CaseIterable {
	case up = "^"
	case down = "v"
	case right = ">"
	case left = "<"
	
	var offset: AoCCoord2D {
		switch self {
		case .up:
			return AoCCoord2D(x: 0, y: -1)
		case .down:
			return AoCCoord2D(x: 0, y: 1)
		case .left:
			return AoCCoord2D(x: -1, y: 0)
		case .right:
			return AoCCoord2D(x: 1, y: 0)
		}
	}
}

enum AoCMapDirection: String, CaseIterable {
	case north = "N"
	case south = "S"
	case east = "E"
	case west = "W"
	
	var offset: AoCCoord2D {
		switch self {
		case .north:
			return AoCCoord2D(x: 0, y: -1)
		case .south:
			return AoCCoord2D(x: 0, y: 1)
		case .west:
			return AoCCoord2D(x: -1, y: 0)
		case .east:
			return AoCCoord2D(x: 1, y: 0)
		}
	}
}


struct AoCExtent2D: Hashable {
	static func build(from coords: [AoCCoord2D]) -> AoCExtent2D {
		if let (xmin, xmax) = AoCUtil.minMaxOf(array: (coords.map { $0.x })),
		   let (ymin, ymax) = AoCUtil.minMaxOf(array: (coords.map { $0.y })) {
			return AoCExtent2D(min: AoCCoord2D(x: xmin, y: ymin), max: AoCCoord2D(x: xmax, y: ymax))
		}
		return AoCExtent2D.zero
	}
	
	static var zero: AoCExtent2D {
		return AoCExtent2D(min: AoCCoord2D(x: 0, y: 0), max: AoCCoord2D(x: 0, y: 0))
	}
	
	let min: AoCCoord2D
	let max: AoCCoord2D
	
	init(min: AoCCoord2D, max: AoCCoord2D) {
		if min.x > max.x || min.y > max.y {
			self.min = AoCCoord2D(x: Swift.min(min.x, max.x), y: Swift.min(min.y, max.y))
			self.max = AoCCoord2D(x: Swift.max(min.x, max.x), y: Swift.max(min.y, max.y))
		}
		else {
			self.min = min
			self.max = max
		}
	}
	
	var width: Int {
		return max.x - min.x + 1
	}
	
	var height: Int {
		return max.y - min.y + 1
	}
	
	var area: Int {
		return width * height
	}
	
	func contains(_ coord: AoCCoord2D) -> Bool {
		return min.x <= coord.x && coord.x <= max.x &&
				min.y <= coord.y && coord.y <= max.y
	}
}

class AoCGrid2D {
	let defaultValue: String
	var _data = Dictionary<AoCCoord2D, Any>()
	var neighbourRule: AoCAdjacencyRule = .rook
	
	init(defaultValue: String = ".") {
		self.defaultValue = defaultValue
	}
	
	var _extent: AoCExtent2D?
	var extent: AoCExtent2D {
		if _extent == nil {
			_extent = AoCExtent2D.build(from: [AoCCoord2D](_data.keys))
		}
		return _extent!
	}
	
	func stringValue(at coord: AoCCoord2D) -> String {
		if let str = value(at: coord) as? String {
			return str
		}
		return defaultValue
	}
	
	func value(at coord: AoCCoord2D) -> Any {
		if let v = _data[coord] {
			return v
		}
		return defaultValue
	}
	
	func setStringValue(_ v: String, at coord: AoCCoord2D) {
		setValue(v, at: coord)
	}
	
	func setValue(_ v: Any, at coord: AoCCoord2D) {
		_data[coord] = v
		if extent.contains(coord) == false { _extent = nil }
	}
	
	var coords: [AoCCoord2D] {
		return Array(_data.keys)
	}
	
	func getCoords(withValue v: String) -> [AoCCoord2D] {
		let result = _data.filter {
			if let str = $0.value as? String {
				return str == v
			}
			return false
		}
		return Array(result.keys)
	}
	
	var counts: Dictionary<String, Int> {
		var result = Dictionary<String, Int>()
		let ext = extent
		for row in ext.min.y...ext.max.y {
			for col in ext.min.x...ext.max.x {
				let v = stringValue(at: AoCCoord2D(x: col, y: row))
				if result.keys.contains(v) == false { result[v] = 0 }
				result[v]! += 1
			}
		}
		return result
	}
	
	var neighbourOffsets: [AoCCoord2D] {
		return AoCCoord2D.getAdjacentOffsets(rule: self.neighbourRule)
	}
	
	func neighbourCoords(at coord: AoCCoord2D) -> [AoCCoord2D] {
		return coord.getAdjacentCoords(rule: self.neighbourRule)
	}
	
	func neighbourCoords(at coord: AoCCoord2D, withValue s: String) -> [AoCCoord2D] {
		var result = neighbourCoords(at: coord)
		result = result.filter { self.stringValue(at: $0) == s }
		return result
	}
	
	func draw(markers: Dictionary<AoCCoord2D, String>? = nil) {
		let ext = extent
		for row in ext.min.y...ext.max.y {
			var values = [String]()
			for col in ext.min.x...ext.max.x {
				let coord = AoCCoord2D(x: col, y: row)
				if let markers = markers,
				   markers.keys.contains(coord) {
					values.append(markers[coord]!)
				}
				else {
					let v = value(at: coord)
					if let marker = v as? String {
						values.append(marker)
					}
					else if let renderable = v as? AoCGridRenderable {
						values.append(renderable.glyph)
					}
					else {
						values.append(defaultValue)
					}
				}
			}
			print(values.joined(separator: " "))
		}
		print("")
	}
}

protocol AoCGridRenderable {
	var glyph: String {get}
}
	
