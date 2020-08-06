//
//  String+AdditionsTests.swift
//  UtilitiesTests
//
//  Created by made2k on 3/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import XCTest
@testable import Utilities

class String_AdditionsTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
  }
  
  override func tearDown() {
    
    super.tearDown()
  }
  
  // MARK: - Manipulation
  
  func test_trimmed() {
    XCTAssertEqual(" leading and trailing ".trimmed, "leading and trailing")
    XCTAssertEqual(" leading".trimmed, "leading")
    XCTAssertEqual("trailing ".trimmed, "trailing")
  }
  
  func test_lowercasedTrim() {
    XCTAssertEqual(" Leading and Trailing ".lowercasedTrim, "leading and trailing")
    XCTAssertEqual(" LEADING".lowercasedTrim, "leading")
    XCTAssertEqual("TRAIling ".lowercasedTrim, "trailing")
  }
  
  func test_withoutWhitespace() {
    XCTAssertEqual(" t e s t ".withoutWhitespace, "test")
    XCTAssertEqual(" T e s T ".withoutWhitespace, "TesT")
  }
  
  // MARK: - Substrings
  
  func test_firstRange() {
    let string = "this is a test of a test"
    
    guard let range = string.firstRange(of: "test") else {
      return XCTFail()
    }
    
    XCTAssertEqual(string.distance(from: string.startIndex, to: range.lowerBound), 10)
    XCTAssertEqual(string.distance(from: string.startIndex, to: range.upperBound), 14)
  }
  
  func test_lastRange() {
    let string = "this is a test of a test"
    
    guard let range = string.lastRange(of: "test") else {
      return XCTFail()
    }
    
    XCTAssertEqual(string.distance(from: string.startIndex, to: range.lowerBound), 20)
    XCTAssertEqual(string.distance(from: string.startIndex, to: range.upperBound), 24)
  }
  
  func test_substringFromTo() {
    XCTAssertEqual(try! "abcdefg".substring(from: 2, to: 5), "cde")
    XCTAssertEqual(try! "abcdefg".substring(from: 0, to: 1), "a")
    XCTAssertEqual(try! "a".substring(from: 0, to: 0), "")
    XCTAssertEqual(try! "a".substring(from: 0, to: 1), "a")
    
    XCTAssertThrowsError(try "abc".substring(from: -1, to: 1))
    XCTAssertThrowsError(try "a".substring(from: 0, to: 2))
  }
  
  func test_substringAfter() {
    XCTAssertEqual("abcabcd".substring(after: "a", options: .literal), "bcabcd")
    XCTAssertEqual("abcabcd".substring(after: "a"), "bcabcd")
    XCTAssertEqual("abcabcd".substring(after: "a", options: .backwards), "bcd")
    XCTAssertNil("abc".substring(after: "1"))
  }
  
  func test_substringBefore() {
    XCTAssertEqual("abcdabcd".substring(before: "d", options: .literal), "abc")
    XCTAssertEqual("abcdabcd".substring(before: "d"), "abc")
    XCTAssertEqual("abcdabcd".substring(before: "d", options: .backwards), "abcdabc")
    XCTAssertNil("abc".substring(before: "1"))
  }
  
  func test_substringOrSelfBefore() {
    XCTAssertEqual("abc".substringOrSelf(before: "1"), "abc")
    XCTAssertEqual("abc".substringOrSelf(before: "c"), "ab")
  }
  
  func test_substringOrSelfAfter() {
    XCTAssertEqual("abc".substringOrSelf(after: "1"), "abc")
    XCTAssertEqual("abc".substringOrSelf(after: "a"), "bc")
  }
  
  func test_substringAfterBefore() {
    XCTAssertEqual("abcdefabc".substring(after: "abc", before: "abc"), "def")
    XCTAssertEqual("abcdefghi".substring(after: "abc", before: "g"), "def")
  }
  
  func test_substringExcluding() {
    XCTAssertEqual("abcdef".stringByCuttingBetween(start: "a", end: "c"), "acdef")
    XCTAssertEqual("abcdef".stringByCuttingBetween(start: "a", end: "f"), "af")
    XCTAssertEqual("test/some/".stringByCuttingBetween(start: "test/", end: "/"), "test//")
  }
  
  // MARK: - Information
  
  func test_numberOfOccurances() {
    XCTAssertEqual("abc123abc123abc".numberOfOccurances(of: "abc"), 3)
    XCTAssertEqual("1111111".numberOfOccurances(of: "1"), 7)
  }
  
  // MARK: - Regular Expressions
  
  func test_match() {
    XCTAssertEqual("this is a test".match(regex: "is").count, 2)
  }
  
  func test_withResult() {
    let string = "this is a test"
    let result = string.match(regex: "( \\w+ )").first!
    XCTAssertEqual(string.with(result: result), " is ")
  }
  
}
