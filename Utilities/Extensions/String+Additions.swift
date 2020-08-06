//
//  String+Additions.swift
//  Utilities
//
//  Created by made2k on 3/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation

public enum StringError: Error {
  case indexOutOfBounds
}

// MARK: - Manipulation

extension String {
  
  public var lowercasedTrim: String {
    return lowercased().trimmed
  }
  
  public var withoutWhitespace: String {
    return components(separatedBy: .whitespaces).joined()
  }
  
  public func replacingFirstOccurance(of string: String, with newString: String) -> String {
    guard let index = firstRange(of: string)?.lowerBound else { return self }
    let range = index..<self.index(index, offsetBy: string.count)
    return replacingCharacters(in: range, with: newString)
  }
  
}

// MARK: - Substrings

extension String {

  public func substring(nsRange: NSRange) -> String {
    return (self as NSString).substring(with: nsRange)
  }

  public func firstRange(of substring: String) -> Range<String.Index>? {
    return range(of: substring, options: NSString.CompareOptions.literal)
  }
  
  public func lastRange(of substring: String) -> Range<String.Index>? {
    return range(of: substring, options: NSString.CompareOptions.backwards)
  }
  
  public func substring(from: Int, to: Int) throws -> String {
    guard from >= 0, to <= self.count else {
      throw StringError.indexOutOfBounds
    }
    
    let start = index(startIndex, offsetBy: from)
    let end = index(startIndex, offsetBy: to)
    return String(self[start..<end])
  }
  
  public func substring(after: String, options: String.CompareOptions = .literal) -> String? {
    
    if let from = range(of: after, options: options, range: nil, locale: nil)?.upperBound {
      return String(self[from..<endIndex])
    }
    
    return nil
  }

  public func substring(before: String, options: String.CompareOptions = .literal) -> String? {
    
    if let range = range(of: before, options: options, range: nil, locale: nil)?.lowerBound {
      return String(self[startIndex..<range])
    }

    return nil
  }

  public func substringOrSelf(before: String, options: String.CompareOptions = .literal) -> String {
    return substring(before: before, options: options) ?? self
  }

  public func substringOrSelf(after: String, options: String.CompareOptions = .literal) -> String {
    return substring(after: after, options: options) ?? self
  }

  public func substring(after: String, before: String) -> String? {
    guard let from = range(of: after)?.upperBound else {
      return nil
    }
    
    // If not comparing between same strings, we can just lookup the before
    if after != before {
      guard let to = range(of: before, range: from..<endIndex)?.lowerBound else {
        return nil
      }
      
      return String(self[from..<to])
      
    } else {
      // We're looking for something between the same characters.
      guard let lastIndex = lastRange(of: before)?.lowerBound else {
        return nil
      }
      let to = index(lastIndex, offsetBy: 0)
      return String(self[from..<to])
    }
  }
  
  /// Return a string exluding the range between start and end
  /// For example: Start: a, end: c, "abcdef" would return "acdef"
  public func stringByCuttingBetween(start: String, end: String) -> String {
    guard
      let startIndex = firstRange(of: start)?.upperBound,
      let endIndex = lastRange(of: end)?.lowerBound, startIndex < endIndex else {
        return self
    }
    
    return replacingCharacters(in: startIndex..<endIndex, with: "")
  }
  
}

// MARK: - Information

extension String {
  
  public func numberOfOccurances(of substring: String) -> Int {
    return components(separatedBy: substring).count - 1
  }
  
  public func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
    var ranges: [Range<Index>] = []
    while let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
      ranges.append(range)
    }
    return ranges
  }
  
  public func nsRanges(of substring: String, options: NSString.CompareOptions) -> [NSRange] {
    
    let nsString = self as NSString
    var searchRange = nsRange
    
    var results: [NSRange] = []
    
    while searchRange.location < nsString.length {
      
      searchRange.length = nsString.length - searchRange.location
      let foundRange = nsString.range(of: substring, options: options, range: searchRange)
      
      if foundRange.location != NSNotFound {
        searchRange.location = foundRange.location + foundRange.length
        results.append(foundRange)
        
      } else {
        break
      }
      
    }
    
    return results
  }
  
  public var nsRange: NSRange {
    return NSRange(location: 0, length: count)
  }
  
}

// MARK: - Regular Expressions

extension String {
  
  public func match(regex: String, options: NSRegularExpression.Options = []) throws -> [NSTextCheckingResult] {
    let expression = try NSRegularExpression(pattern: regex, options: options)
    return expression.matches(in: self, range: nsRange)
  }
  
  public func with(result: NSTextCheckingResult, at index: Int? = nil) -> String {
    if let index = index {
      return (self as NSString).substring(with: result.range(at: index))
    }
    
    return (self as NSString).substring(with: result.range)
  }
}
