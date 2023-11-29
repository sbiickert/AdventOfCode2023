//
//  AoCSolutionTests.swift
//  AoC2023Tests
//
//  Created by Simon Biickert on 2023-11-27.
//

import XCTest

final class AoCSolutionTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testListSolutions() throws {
		let solutions = AoCSolution.solutions
		XCTAssert(solutions.isEmpty == false)
		XCTAssert(solutions.last?.day == 0)
	}
	
	func testSolve() throws {
		let s = AoCSolution.solutions.last!
		let i = AoCInput.inputsFor(solution: s)
		let r1 = s.solve(i[0])
		print("\(r1)")
		let r2 = s.solve(i[2])
		print("\(r2)")
	}
}
