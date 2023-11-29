//
//  AoCInputTests.swift
//  AoC2023Tests
//
//  Created by Simon Biickert on 2023-11-27.
//

import XCTest

final class AoCInputTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testInput() throws {
		let s = AoCSolution.solutions.last!
		let i = AoCInput.inputsFor(solution: s)
		XCTAssert(i.isEmpty == false)
		XCTAssert(i.count == 4)
		let challenge = i.first!
		NSLog("\(challenge.fileName)")
		XCTAssert(challenge.fileName.contains("challenge"))
		NSLog("\(challenge.inputPath)")
		let challengeInput = challenge.textLines
		XCTAssert(challengeInput.count == 3)
		XCTAssert(challengeInput[1] == "G0, L1")
		let test1 = i[2] // i[0] is challenge
		NSLog("\(test1.fileName)")
		XCTAssert(test1.fileName.contains("test"))
		NSLog("\(test1.inputPath)")
		let testInput = test1.textLines
		XCTAssert(testInput.count == 2)
		XCTAssert(testInput[0] == "G1, L0")
	}
}
