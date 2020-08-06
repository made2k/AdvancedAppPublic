//
//  RedditTests.swift
//  RedditTests
//
//  Created by made2k on 2/15/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import XCTest
@testable import Reddit

class RedditTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
      let string = "https://reddit.com/r/reddit.com/test"
      let result = string.replacingFirstOccurance(of: "reddit.com", with: "oauth.reddit.com")
      XCTAssertEqual(result, "https://oauth.reddit.com/r/reddit.com/test")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
