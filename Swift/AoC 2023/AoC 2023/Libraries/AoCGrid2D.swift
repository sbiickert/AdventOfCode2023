//
//  AoCGrid2D.swift
//  AoC 2023
//
//  Created by Simon Biickert on 2023-11-27.
//

import Foundation

class AoCGrid2D {
	let defaultValue: String
	private var _data = Dictionary<AoCCoord2D, Any>()
	private var _adjacencyRule: AoCAdjacencyRule = .rook
	private var _extent: AoCExtent2D?

	init(defaultValue: String = ".", rule: AoCAdjacencyRule = .rook) {
		self.defaultValue = defaultValue
		_adjacencyRule = rule
		_extent = nil
	}
	
	var rule: AoCAdjacencyRule {
		return _adjacencyRule
	}
	
	var extent: AoCExtent2D? {
		return _extent
	}

	func stringValue(at coord: AoCCoord2D) -> String {
		let val = value(at: coord)
		return AoCGrid2D.transformToString(value: val)
	}
	
	private static func transformToString(value: Any) -> String {
		if let str = value as? String {
			return str
		}
		else if let renderable = value as? AoCGridRenderable {
			return renderable.glyph
		}
		return "\(value)"
	}
	
	func value(at coord: AoCCoord2D) -> Any {
		if let v = _data[coord] {
			return v
		}
		return defaultValue
	}
	
	func setValue(_ v: Any, at coord: AoCCoord2D) {
		_data[coord] = v
		if extent == nil {
			_extent = AoCExtent2D(min: coord, max: coord)
		}
		else {
			_extent = extent!.expanded(toFit: coord)
		}
	}
	
	func clear(at coord: AoCCoord2D, resetExtent: Bool = false) {
		_data.removeValue(forKey: coord)
		if (resetExtent) {
			_extent = AoCExtent2D.build(from: coords)
		}
	}
	
	var coords: [AoCCoord2D] {
		return Array(_data.keys)
	}
	
	func getCoords(withValue v: String) -> [AoCCoord2D] {
		let result = _data.filter {
			let str = AoCGrid2D.transformToString(value: $0.value)
			return str == v
		}
		return Array(result.keys)
	}
	
	var histogram: Dictionary<String, Int> {
		var result = Dictionary<String, Int>()
		if let ext = extent {
			for row in ext.min.y...ext.max.y {
				for col in ext.min.x...ext.max.x {
					let v = stringValue(at: AoCCoord2D(x: col, y: row))
					if result.keys.contains(v) == false { result[v] = 0 }
					result[v]! += 1
				}
			}
		}
		return result
	}
	
	var neighbourOffsets: [AoCCoord2D] {
		return AoCCoord2D.getAdjacentOffsets(rule: self.rule)
	}
	
	func neighbourCoords(at coord: AoCCoord2D) -> [AoCCoord2D] {
		return coord.getAdjacentCoords(rule: self.rule)
	}
	
	func neighbourCoords(at coord: AoCCoord2D, withValue s: String) -> [AoCCoord2D] {
		var result = neighbourCoords(at: coord)
		result = result.filter { self.stringValue(at: $0) == s }
		return result
	}
	
	func toString(markers: Dictionary<AoCCoord2D, String>? = nil) -> String {
		var str = ""
		if let ext = extent {
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
				str.append(values.joined(separator: " "))
				str.append("\n")
			}
		}
		return str
	}
	
	func draw(markers: Dictionary<AoCCoord2D, String>? = nil) {
		print(self.toString(markers: markers))
	}
}

protocol AoCGridRenderable {
	var glyph: String {get}
}
	
