//
//  Int+AdditionsTests.swift
//  UtilitiesTests
//
//  Created by made2k on 3/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import XCTest
@testable import Utilities

class Int_AdditionsTests: XCTestCase {
  
  override func setUp() {
    super.setUp()

  }
  
  override func tearDown() {

    super.tearDown()
  }
  
  func test_seconds() {
    XCTAssertEqual(1.seconds, TimeInterval(1))
    XCTAssertEqual(5.seconds, TimeInterval(5))
    XCTAssertEqual(7.seconds, TimeInterval(7))
    XCTAssertEqual(100.seconds, TimeInterval(100))
  }
  
  func test_minutes() {
    XCTAssertEqual(1.minutes, TimeInterval(60))
    XCTAssertEqual(2.minutes, TimeInterval(120))
    XCTAssertEqual(5.minutes, TimeInterval(300))
  }
  
  func test_hours() {
    XCTAssertEqual(1.hours, TimeInterval(3600))
    XCTAssertEqual(5.hours, TimeInterval(5 * 60 * 60))
    XCTAssertEqual(24.hours, TimeInterval(24 * 60 * 60))
  }
  
  func test_days() {
    XCTAssertEqual(1.days, TimeInterval(1 * 24 * 60 * 60))
    XCTAssertEqual(5.days, TimeInterval(5 * 24 * 60 * 60))
    XCTAssertEqual(7.days, TimeInterval(7 * 24 * 60 * 60))
  }
  
  func test_weeks() {
    XCTAssertEqual(1.week, TimeInterval(1 * 7 * 24 * 60 * 60))
    XCTAssertEqual(2.week, TimeInterval(2 * 7 * 24 * 60 * 60))
    XCTAssertEqual(3.week, TimeInterval(3 * 7 * 24 * 60 * 60))
  }
  
}
