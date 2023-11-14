//
//  AoCSpatialTests.swift
//  AoC 2023Tests
//
//  Created by Simon Biickert on 2023-04-27.
//

import XCTest
@testable import AoC_2023

final class AoCSpatialTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testCoord2D_create() throws {
		let c1 = AoCCoord2D(x: 1, y: 3)
		XCTAssert(c1.x == 1)
		XCTAssert(c1.y == 3)
	}
	
	func testCoord2D_math() throws {
		let c1 = AoCCoord2D(x: 1, y: 3)
		let c2 = AoCCoord2D(x: 10, y: 30)
		
		let sum = c1 + c2
		XCTAssert(sum.x == 11)
		XCTAssert(sum.y == 33)
		
		let diff = c2 - c1
		XCTAssert(diff.x == 9)
		XCTAssert(diff.y == 27)
	}
	
	
	func testCoord2D_distance() throws {
		let c1 = AoCCoord2D(x: 1, y: 3)
		let c2 = AoCCoord2D(x: 10, y: 30)
		
		let d = c1.distance(to: c2)
		XCTAssert(d > 28 && d < 29)
		
		let md = c1.manhattanDistance(to: c2)
		XCTAssert(md == 36)
	}
	
	func testCoord2D_adjacent() throws {
		let c1 = AoCCoord2D(x: 1, y: 3)
		let c2 = AoCCoord2D(x: 10, y: 30)
		let horiz = AoCCoord2D(x: 2, y: 3)
		let vert = AoCCoord2D(x: 1, y: 2)
		let diag = AoCCoord2D(x: 2, y: 2)

		XCTAssert(c1.isAdjacent(to: c2) == false)
		XCTAssert(c1.isAdjacent(to: c2, rule: .bishop) == false)
		XCTAssert(c1.isAdjacent(to: c2, rule: .queen) == false)
		
		XCTAssert(c1.isAdjacent(to: horiz) == true)
		XCTAssert(c1.isAdjacent(to: horiz, rule: .bishop) == false)
		XCTAssert(c1.isAdjacent(to: horiz, rule: .queen) == true)
		
		XCTAssert(c1.isAdjacent(to: vert) == true)
		XCTAssert(c1.isAdjacent(to: vert, rule: .bishop) == false)
		XCTAssert(c1.isAdjacent(to: vert, rule: .queen) == true)
		
		XCTAssert(c1.isAdjacent(to: diag) == false)
		XCTAssert(c1.isAdjacent(to: diag, rule: .bishop) == true)
		XCTAssert(c1.isAdjacent(to: diag, rule: .queen) == true)
		
		var offsets = AoCCoord2D.getAdjacentOffsets()
		XCTAssert(offsets.count == 4)
		XCTAssert(offsets[0] == AoCCoord2D(x: -1, y: 0))
		offsets = AoCCoord2D.getAdjacentOffsets(rule: .bishop)
		XCTAssert(offsets.count == 4)
		offsets = AoCCoord2D.getAdjacentOffsets(rule: .queen)
		XCTAssert(offsets.count == 8)
		
		var adj = c1.getAdjacentCoords()
		XCTAssert(adj.count == 4)
		XCTAssert(adj[0] == AoCCoord2D(x: 0, y: 3))
		adj = c1.getAdjacentCoords(rule: .bishop)
		XCTAssert(adj.count == 4)
		XCTAssert(adj[0] == AoCCoord2D(x: 0, y: 2))
		adj = c1.getAdjacentCoords(rule: .queen)
		XCTAssert(adj.count == 8)
		XCTAssert(adj[7] == AoCCoord2D(x: 0, y: 4))
	}
	
	func testCoord2D_direction() throws {
		let c1 = AoCCoord2D.zero // 0,0
		
		let north = AoCMapDirection(rawValue: "N")
		XCTAssert(north == AoCMapDirection.north)
		
		let n = c1 + AoCMapDirection.north.offset
		XCTAssert(n.x == 0 && n.y == -1)
		let e = c1 + AoCMapDirection.east.offset
		XCTAssert(e.x == 1 && e.y == 0)
		let s = c1 + AoCMapDirection.south.offset
		XCTAssert(s.x == 0 && s.y == 1)
		let w = c1 + AoCMapDirection.west.offset
		XCTAssert(w.x == -1 && w.y == 0)
		
		let up = AoCDirection(rawValue: "^")
		XCTAssert(up == AoCDirection.up)
		
		let u = c1 + AoCDirection.up.offset
		XCTAssert(u.x == 0 && u.y == -1)
		let r = c1 + AoCDirection.right.offset
		XCTAssert(r.x == 1 && r.y == 0)
		let d = c1 + AoCDirection.down.offset
		XCTAssert(d.x == 0 && d.y == 1)
		let l = c1 + AoCDirection.left.offset
		XCTAssert(l.x == -1 && l.y == 0)
	}
	
	func testExtent2D_create() throws {
		let e1 = AoCExtent2D(min: AoCCoord2D.zero, max: AoCCoord2D(x: 10, y: 5))
		XCTAssert(e1.min.x == 0 && e1.min.y == 0 && e1.max.x == 10 && e1.max.y == 5)
		XCTAssert(e1.width == 11 && e1.height == 6)
		XCTAssert(e1.area == 66)

		let e2 = AoCExtent2D(min: AoCCoord2D.zero, max: AoCCoord2D(x: -10, y: -5))
		XCTAssert(e2.max.x == 0 && e2.max.y == 0 && e2.min.x == -10 && e2.min.y == -5)
		XCTAssert(e2.width == 11 && e2.height == 6)
		XCTAssert(e2.area == 66)

		let c1 = AoCCoord2D(x: 1, y: 1)
		let c2 = AoCCoord2D(x: 10, y: 10)
		let c3 = AoCCoord2D(x: 2, y: -5)
		let e3 = AoCExtent2D.build(from: [c1, c2, c3])
		XCTAssert(e3.min.x == 1 && e3.min.y == -5 && e3.max.x == 10 && e3.max.y == 10)
		XCTAssert(e3.width == 10 && e3.height == 16)
		XCTAssert(e3.area == 160)
	}
	
	func testExtent2D_relations() throws {
		let e1 = AoCExtent2D(min: AoCCoord2D.zero, max: AoCCoord2D(x: 10, y: 5))
		
		XCTAssert(e1.contains(AoCCoord2D(x: 1, y: 1)) == true)
		XCTAssert(e1.contains(AoCCoord2D(x: 10, y: 1)) == true)
		XCTAssert(e1.contains(AoCCoord2D(x: 11, y: 1)) == false)
		XCTAssert(e1.contains(AoCCoord2D(x: -1, y: -1)) == false)
	}
	
	func testGrid2D_create() throws {
		let g1 = AoCGrid2D()
		XCTAssert(g1.defaultValue == ".")
		XCTAssert(g1.neighbourRule == .rook)
		XCTAssert(g1.extent == AoCExtent2D.zero)

		let g2 = AoCGrid2D(defaultValue: "x")
		g2.neighbourRule = .queen
		XCTAssert(g2.defaultValue == "x")
		XCTAssert(g2.neighbourRule == .queen)
		XCTAssert(g2.extent == AoCExtent2D.zero)
	}
	
	func testGrid2D_values() throws {
		let g1 = AoCGrid2D()
		g1.setStringValue("@", at: AoCCoord2D.zero)
		XCTAssert(g1.extent.width == 1 && g1.extent.height == 1)
		let at = g1.stringValue(at: AoCCoord2D.zero)
		XCTAssert(at == "@")
		
		g1.setStringValue("!", at: AoCCoord2D(x: 5, y: 4))
		XCTAssert(g1.extent.width == 6 && g1.extent.height == 5)
		let excl = g1.stringValue(at: AoCCoord2D(x: 5, y: 4))
		XCTAssert(excl == "!")
		
		let def = g1.stringValue(at: AoCCoord2D(x: 10, y: 10))
		XCTAssert(def == g1.defaultValue)
		
		let sample = SampleRenderable(letter: "Pig")
		g1.setValue(sample, at: AoCCoord2D(x: -1, y: -1))
		let sampleStr = g1.stringValue(at: AoCCoord2D(x: -1, y: -1))
		XCTAssert(sampleStr == g1.defaultValue)
		if let sampleVal = g1.value(at: AoCCoord2D(x: -1, y: -1)) as? SampleRenderable {
			XCTAssert(sampleVal == sample)
		}
		
		let coords = g1.coords
		XCTAssert(coords.count == 3) // Doesn't include defaults
		
		let counts = g1.counts
		XCTAssert(counts.count == 3) // Doesn't include non-String value
	}
	
	func testGrid2D_coords() throws {
		let g1 = AoCGrid2D()
		g1.setStringValue("@", at: AoCCoord2D.zero)
		g1.setStringValue("!", at: AoCCoord2D(x: 5, y: 4))

		let offsets = g1.neighbourOffsets
		XCTAssert(offsets.count == 4)
		
		let coords = g1.neighbourCoords(at: AoCCoord2D.zero)
		XCTAssert(coords.count == 4)
		XCTAssert(coords[0].isAdjacent(to: AoCCoord2D.zero, rule: g1.neighbourRule))
		
		g1.setStringValue("A", at: AoCCoord2D(x: 1, y: 0))
		g1.setStringValue("B", at: AoCCoord2D(x: 0, y: 1))
		let coordsWithA = g1.neighbourCoords(at: AoCCoord2D.zero, withValue: "A")
		XCTAssert(coordsWithA.count == 1)
		XCTAssert(coordsWithA[0] == AoCCoord2D(x: 1, y: 0))
	}
	
	func testGrid2D_draw() throws {
		let g1 = AoCGrid2D()
		g1.setStringValue("@", at: AoCCoord2D.zero)
		g1.setStringValue("!", at: AoCCoord2D(x: 5, y: 4))
		g1.setValue(SampleRenderable(letter: "Pig"), at: AoCCoord2D(x: 5, y: 5))

		let coords = g1.neighbourCoords(at: AoCCoord2D.zero)
		for coord in coords {
			g1.setStringValue("N", at: coord)
		}

		g1.draw()
		
		var markers = Dictionary<AoCCoord2D, String>()
		markers[AoCCoord2D(x: 3, y: 4)] = "*"
		markers[AoCCoord2D(x: 0, y: 8)] = "&" // Will not draw, outside extent
		
		g1.draw(markers: markers)
	}
}

struct SampleRenderable: AoCGridRenderable, Equatable {
	let letter: String
	
	var glyph: String {
		if letter.isEmpty == false {
			return "\(letter[0])"
		}
		return "X"
	}
}
