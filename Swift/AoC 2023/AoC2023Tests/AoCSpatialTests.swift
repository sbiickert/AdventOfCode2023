//
//  AoCSpatialTests.swift
//  AoC 2023Tests
//
//  Created by Simon Biickert on 2023-04-27.
//

import XCTest
//@testable import AoC_2023

final class AoCSpatialTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testDir() throws {
		var up = AoCDir.fromAlias("^")
		XCTAssert(up == AoCDir.north)
		up = AoCDir.fromAlias("up")
		XCTAssert(up == AoCDir.north)
		up = AoCDir.fromAlias("u")
		XCTAssert(up == AoCDir.north)

		let left = AoCDir.fromAlias("left")
		XCTAssert(left == AoCDir.west)
	}
	
	func testTurn() throws {
		let up = AoCDir.north
		let left = AoCTurn.left.apply(to: up)
		XCTAssertEqual(left, AoCDir.west)
		var dir = up
		for _ in 0...5 {
			dir = AoCTurn.right.apply(to: dir)
		}
		XCTAssertEqual(dir, AoCDir.south)
		
		dir = up
		for _ in 0...6 {
			dir = AoCTurn.left.apply(to: dir, size: .fortyFive)
		}
		XCTAssertEqual(dir, .ne)
		
		let noTurn = AoCTurn.fromAlias("nothing")
		dir = noTurn.apply(to: up)
		XCTAssertEqual(dir, up)
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
		XCTAssertEqual(sum - c1, c2)

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
		XCTAssert(offsets[0] == AoCCoord2D(x: 0, y: -1))
		offsets = AoCCoord2D.getAdjacentOffsets(rule: .bishop)
		XCTAssert(offsets.count == 4)
		offsets = AoCCoord2D.getAdjacentOffsets(rule: .queen)
		XCTAssert(offsets.count == 8)
		
		var adj = c1.getAdjacentCoords()
		XCTAssert(adj.count == 4)
		XCTAssert(adj[0] == AoCCoord2D(x: 1, y: 2))
		adj = c1.getAdjacentCoords(rule: .bishop)
		XCTAssert(adj.count == 4)
		XCTAssert(adj[0] == AoCCoord2D(x: 0, y: 2))
		adj = c1.getAdjacentCoords(rule: .queen)
		XCTAssert(adj.count == 8)
		XCTAssert(adj[7] == AoCCoord2D(x: 2, y: 4))
	}
	
	func testCoord2D_direction() throws {
		let c1 = AoCCoord2D.origin // 0,0
		
		let north = AoCDir(rawValue: "N")
		XCTAssert(north == AoCDir.north)
		
		var n = c1 + AoCDir.north.offset
		XCTAssert(n.x == 0 && n.y == -1)
		n = c1.offset(direction: .north) // Equivalent operation
		XCTAssert(n.x == 0 && n.y == -1)
		let e = c1 + AoCDir.east.offset
		XCTAssert(e.x == 1 && e.y == 0)
		let s = c1 + AoCDir.south.offset
		XCTAssert(s.x == 0 && s.y == 1)
		let w = c1 + AoCDir.west.offset
		XCTAssert(w.x == -1 && w.y == 0)
	}
	
	func testPos2D() throws {
		let p1 = AoCPos2D(location: AoCCoord2D.origin, direction: .north)
		var moved = p1.movedForward()
		XCTAssertEqual(moved.location, p1.location.offset(direction: .north))
		moved = p1.movedForward(distance: 10)
		XCTAssertEqual(moved.location, AoCCoord2D(x: 0, y: -10))
		
		let turned = p1.turned(.right)
		moved = turned.movedForward()
		XCTAssertEqual(moved.location, AoCCoord2D(x: 1, y: 0))
	}
	
	func testExtent2D_create() throws {
		let e1 = AoCExtent2D(min: AoCCoord2D.origin, max: AoCCoord2D(x: 10, y: 5))
		XCTAssert(e1.min.x == 0 && e1.min.y == 0 && e1.max.x == 10 && e1.max.y == 5)
		XCTAssert(e1.width == 11 && e1.height == 6)
		XCTAssert(e1.area == 66)

		let e2 = AoCExtent2D(min: AoCCoord2D.origin, max: AoCCoord2D(x: -10, y: -5))
		XCTAssert(e2.max.x == 0 && e2.max.y == 0 && e2.min.x == -10 && e2.min.y == -5)
		XCTAssert(e2.width == 11 && e2.height == 6)
		XCTAssert(e2.area == 66)

		let c1 = AoCCoord2D(x: 1, y: 1)
		let c2 = AoCCoord2D(x: 10, y: 10)
		let c3 = AoCCoord2D(x: 2, y: -5)
		var temp = AoCExtent2D.build(from: [c1, c2, c3])
		XCTAssertNotNil(temp)
		if let e3 = temp {
			XCTAssert(e3.min.x == 1 && e3.min.y == -5 && e3.max.x == 10 && e3.max.y == 10)
			XCTAssert(e3.width == 10 && e3.height == 16)
			XCTAssert(e3.area == 160)
		}
		temp = AoCExtent2D.build(from: [AoCCoord2D]())
		XCTAssertNil(temp)
		
		let e4 = AoCExtent2D.build(1, 2, 3, 4)
		XCTAssert(e4.min.x == 1 && e4.min.y == 2 && e4.max.x == 3 && e4.max.y == 4)
	}
	
	func testExtent2D_modify() throws {
		let e1 = AoCExtent2D(min: AoCCoord2D.origin, max: AoCCoord2D(x: 10, y: 5))
		let expanded = e1.expanded(toFit: AoCCoord2D(x: -5, y: 6))
		XCTAssert(expanded.min.x == -5 && expanded.min.y == 0 &&
				  expanded.max.x == 10 && expanded.max.y == 6)

		let inset = e1.inset(amount: 2)
		XCTAssertNotNil(inset)
		XCTAssert(inset!.min.x == 2 && inset!.min.y == 2 &&
				  inset!.max.x == 8 && inset!.max.y == 3)
		XCTAssertNil(e1.inset(amount: 3))
	}
	
	func testExtent2D_coords() throws {
		let e1 = AoCExtent2D(min: AoCCoord2D.origin, max: AoCCoord2D(x: 5, y: 6))
		let coords = e1.allCoords
		XCTAssertEqual(coords.count, e1.area)
	}
	
	func testExtent2D_relations() throws {
		let e1 = AoCExtent2D(min: AoCCoord2D.origin, max: AoCCoord2D(x: 10, y: 5))
		
		XCTAssert(e1.contains(AoCCoord2D(x: 1, y: 1)) == true)
		XCTAssert(e1.contains(AoCCoord2D(x: 10, y: 1)) == true)
		XCTAssert(e1.contains(AoCCoord2D(x: 11, y: 1)) == false)
		XCTAssert(e1.contains(AoCCoord2D(x: -1, y: -1)) == false)
		
		let e = AoCExtent2D.build(1,1,10,10)
		var i = e.intersect(other: AoCExtent2D.build(5,5,12,12))
		XCTAssertEqual(i, AoCExtent2D.build(5,5,10,10))
		i = e.intersect(other: AoCExtent2D.build(5,5,7,7))
		XCTAssertEqual(i, AoCExtent2D.build(5,5,7,7))
		i = e.intersect(other: AoCExtent2D.build(1,1,12,2))
		XCTAssertEqual(i, AoCExtent2D.build(1,1,10,2))
		i = e.intersect(other: AoCExtent2D.build(11,11,12,12))
		XCTAssertNil(i)
		i = e.intersect(other: AoCExtent2D.build(1,10,10,20))
		XCTAssertEqual(i, AoCExtent2D.build(1,10,10,10))
		
		var products = e.union(other: AoCExtent2D.build(5,5,12,12))
		var expected = [AoCExtent2D.build(5,5,10,10),
						AoCExtent2D.build(1,1,4,4),
						AoCExtent2D.build(1,5,4,10),
						AoCExtent2D.build(5,1,10,4),
						AoCExtent2D.build(11,11,12,12),
						AoCExtent2D.build(11,5,12,10),
						AoCExtent2D.build(5,11,10,12)]
		XCTAssertTrue(verifyUnionResults(actual: products, expected: expected))
		products = e.union(other: AoCExtent2D.build(5,5,7,7))
		expected = [AoCExtent2D.build(5,5,7,7),
					AoCExtent2D.build(1,1,4,4),
					AoCExtent2D.build(1,8,4,10),
					AoCExtent2D.build(1,5,4,7),
					AoCExtent2D.build(8,1,10,4),
					AoCExtent2D.build(8,8,10,10),
					AoCExtent2D.build(8,5,10,7),
					AoCExtent2D.build(5,1,7,4),
					AoCExtent2D.build(5,8,7,10)]
		XCTAssertTrue(verifyUnionResults(actual: products, expected: expected))
		products = e.union(other: AoCExtent2D.build(1,1,12,2))
		expected = [AoCExtent2D.build(1,1,10,2),
					AoCExtent2D.build(1,3,10,10),
					AoCExtent2D.build(11,1,12,2)]
		XCTAssertTrue(verifyUnionResults(actual: products, expected: expected))
		products = e.union(other: AoCExtent2D.build(11,11,12,12))
		expected = [AoCExtent2D.build(11,11,12,12)];
		expected = [AoCExtent2D.build(1,1,10,10),
					AoCExtent2D.build(11,11,12,12)]
		XCTAssertTrue(verifyUnionResults(actual: products, expected: expected))
		products = e.union(other: AoCExtent2D.build(1,10,10,20))
		expected = [AoCExtent2D.build(1,10,10,10),
					AoCExtent2D.build(1,1,10,9),
					AoCExtent2D.build(1,11,10,20)]
		XCTAssertTrue(verifyUnionResults(actual: products, expected: expected))
	}
	
	private func verifyUnionResults(actual: [AoCExtent2D], expected: [AoCExtent2D]) -> Bool {
		if actual.count != expected.count { return false }
		for i in 0..<actual.count {
			if actual[i] != expected[i] {
				print("actual[\(i)]: \(actual[i]), expected[\(i)]: \(expected[i])")
				return false
			}
		}
		return true
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
