//
//  AoCGridTests.swift
//  AoC2023Tests
//
//  Created by Simon Biickert on 2023-11-27.
//

import XCTest

final class AoCGridTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testGrid2D_create() throws {
		let g1 = AoCGrid2D()
		XCTAssert(g1.defaultValue == ".")
		XCTAssert(g1.rule == .rook)
		XCTAssertNil(g1.extent)

		let g2 = AoCGrid2D(defaultValue: "x", rule: .queen)
		XCTAssert(g2.defaultValue == "x")
		XCTAssert(g2.rule == .queen)
		XCTAssertNil(g2.extent)
	}
	
	func testGrid2D_values() throws {
		let g1 = AoCGrid2D()
		g1.setValue("@", at: AoCCoord2D.origin)
		XCTAssertNotNil(g1.extent)
		XCTAssert(g1.extent!.width == 1 && g1.extent!.height == 1)
		let at = g1.stringValue(at: AoCCoord2D.origin)
		XCTAssert(at == "@")
		
		g1.setValue("!", at: AoCCoord2D(x: 5, y: 4))
		XCTAssertNotNil(g1.extent)
		XCTAssert(g1.extent!.width == 6 && g1.extent!.height == 5)
		let excl = g1.stringValue(at: AoCCoord2D(x: 5, y: 4))
		XCTAssert(excl == "!")
		
		let def = g1.stringValue(at: AoCCoord2D(x: 10, y: 10))
		XCTAssert(def == g1.defaultValue)
		
		let sample = SampleRenderable(letter: "Pig")
		g1.setValue(sample, at: AoCCoord2D(x: -1, y: -1))
		let sampleStr = g1.stringValue(at: AoCCoord2D(x: -1, y: -1))
		XCTAssert(sampleStr == "P")
		if let sampleVal = g1.value(at: AoCCoord2D(x: -1, y: -1)) as? SampleRenderable {
			XCTAssert(sampleVal == sample)
		}
		
		let coords = g1.coords
		XCTAssert(coords.count == 3) // Doesn't include defaults
		
		let counts = g1.histogram
		XCTAssert(counts.count == 4)
	}
	
	func testGrid2D_coords() throws {
		let g1 = AoCGrid2D()
		g1.setValue("@", at: AoCCoord2D.origin)
		g1.setValue("!", at: AoCCoord2D(x: 5, y: 4))

		let offsets = g1.neighbourOffsets
		XCTAssert(offsets.count == 4)
		
		let coords = g1.neighbourCoords(at: AoCCoord2D.origin)
		XCTAssert(coords.count == 4)
		XCTAssert(coords[0].isAdjacent(to: AoCCoord2D.origin, rule: g1.rule))
		
		g1.setValue("A", at: AoCCoord2D(x: 1, y: 0))
		g1.setValue("B", at: AoCCoord2D(x: 0, y: 1))
		let coordsWithA = g1.neighbourCoords(at: AoCCoord2D.origin, withValue: "A")
		XCTAssert(coordsWithA.count == 1)
		XCTAssert(coordsWithA[0] == AoCCoord2D(x: 1, y: 0))
	}
	
	func testGrid2D_draw() throws {
		let g1 = AoCGrid2D()
		g1.setValue("@", at: AoCCoord2D.origin)
		g1.setValue("!", at: AoCCoord2D(x: 5, y: 4))
		g1.setValue(SampleRenderable(letter: "Pig"), at: AoCCoord2D(x: 5, y: 5))

		let coords = g1.neighbourCoords(at: AoCCoord2D.origin)
		for coord in coords {
			g1.setValue("N", at: coord)
		}

		g1.draw()
		
		var markers = Dictionary<AoCCoord2D, String>()
		markers[AoCCoord2D(x: 3, y: 4)] = "*"
		markers[AoCCoord2D(x: 0, y: 8)] = "&" // Will not draw, outside extent
		
		g1.draw(markers: markers)
	}
}
