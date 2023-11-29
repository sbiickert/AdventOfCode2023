//
//  AoCStringTests.swift
//  AoC 2023Tests
//
//  Created by Simon Biickert on 2023-04-26.
//

import XCTest
//@testable import AoC_2023

final class AoCStringTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSubscripts() throws {
        var testString = "Life, the Universe and Everything." //34 long
        var firstChar = testString[0]
        XCTAssert(firstChar == "L")
        let lastChar = testString[33]
        XCTAssert(lastChar == ".")
        testString[0] = "W"
        firstChar = testString[0]
        XCTAssert(firstChar == "W")
    }

    func testIndexes() throws {
        let testString = "Life, the Universe and Everything." //34 long
        let i = testString.indexesOf(string: "e")
        NSLog("\(i)")
        XCTAssert(i == [3, 8, 14, 17, 25])
        let iFail = testString.indexesOf(string: "x")
        XCTAssert(iFail.isEmpty)
    }

}
