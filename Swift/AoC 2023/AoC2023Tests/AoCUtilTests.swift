//
//  AoCUtilTest.swift
//  AoC 2023Tests
//
//  Created by Simon Biickert on 2023-04-26.
//

import XCTest
//@testable import AoC_2023

final class AoCUtilTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
