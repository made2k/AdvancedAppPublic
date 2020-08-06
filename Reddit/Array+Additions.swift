//
//  Array+Additions.swift
//  Reddit
//
//  Created by made2k on 10/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

extension Array {
  
  /// If the value is greater than the capacity of the array, it will loop back to the start
  public subscript (loop index: Int) -> Element {
    return self[index % self.count]
  }
  
}

extension Array {
  
  func chunk(_ chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize).map({ (startIndex) -> [Element] in
      let endIndex = (startIndex.advanced(by: chunkSize) > self.count) ? self.count-startIndex : chunkSize
      return Array(self[startIndex..<startIndex.advanced(by: endIndex)])
    })
  }

  mutating func append(_ optional: Element?) {
    guard let value = optional else { return }
    append(value)
  }
  
  mutating func insert(_ optional: Element?, at index: Int) {
    guard let value = optional else { return }
    insert(value, at: index)
  }

}

extension Array where Element: Equatable {

  @discardableResult
  mutating func remove(_ element: Element) -> Element? {
    if let index = self.firstIndex(of: element) {
      return remove(at: index)
    }
    return nil
  }
}
