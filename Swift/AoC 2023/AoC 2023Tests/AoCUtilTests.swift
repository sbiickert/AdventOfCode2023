//
//  AoCUtilTest.swift
//  AoC 2023Tests
//
//  Created by Simon Biickert on 2023-04-26.
//

import XCTest
@testable import AoC_2023

final class AoCUtilTests: XCTestCase {

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
    
    func testSolve() async throws {
        let s = AoCSolution.solutions.last!
        let i = AoCInput.inputsFor(solution: s)
        let r1 = await s.solve(input: i[0])
        print("\(r1)")
        let r2 = await s.solve(input: i[2])
        print("\(r2)")
    }
    
    func testRangeConversion() throws {
        let openRange = 0..<10
        let openInts = AoCUtil.rangeToArray(r: openRange)
        XCTAssert(openInts.count == 10)
        XCTAssert(openInts[5] == 5)
        let closedRange = 0...10
        let closedInts = AoCUtil.cRangeToArray(r: closedRange)
        XCTAssert(closedInts.count == 11)
        XCTAssert(closedInts[6] == 6)
    }
    
    func testNumToIntArray() throws {
        let num = "987654"
        let ints = AoCUtil.numberToIntArray(num)
        XCTAssert(ints.count == 6)
        XCTAssert(ints[1] == 8)
    }
}
