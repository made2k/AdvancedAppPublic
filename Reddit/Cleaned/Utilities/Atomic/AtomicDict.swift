//
//  AtomicDict.swift
//  Reddit
//
//  Created by made2k on 4/26/20.
//  Copyright © 2020 made2k. All rights reserved.
//
// Referenced from:
// https://www.donnywals.com/why-your-atomic-property-wrapper-doesnt-work-for-collection-types/?utm_campaign=iOS%2BDev%2BWeekly&utm_medium=web&utm_source=iOS%2BDev%2BWeekly%2BIssue%2B453

import Foundation

final class AtomicDict<Key: Hashable, Value>: CustomDebugStringConvertible, ExpressibleByDictionaryLiteral {

  private var dictStorage: [Key: Value] = [:]
  private let queue = DispatchQueue(
    label: "com.advancedapp.\(UUID().uuidString)",
    qos: .utility,
    attributes: .concurrent,
    autoreleaseFrequency: .inherit,
    target: .global()
  )

  var dictValue: [Key: Value] {
    queue.sync {
      dictStorage
    }
  }

  init(dictionaryLiteral elements: (Key, Value)...) {

    for element in elements {
      dictStorage[element.0] = element.1
    }

  }

  public subscript(key: Key) -> Value? {
    get {
      queue.sync {
        dictStorage[key]
      }
    }
    set {
      queue.async(flags: .barrier) { [weak self] in
        self?.dictStorage[key] = newValue
      }
    }
  }

  public var debugDescription: String {
    return dictStorage.debugDescription
  }

}
