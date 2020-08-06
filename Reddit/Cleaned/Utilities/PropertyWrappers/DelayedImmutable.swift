//
//  DelayedImmutable.swift
//  Reddit
//
//  Created by made2k on 1/29/20.
//  Copyright © 2020 made2k. All rights reserved.
//

/**
 Allow for delayed initialization of an immutable value.
 Attempting to access this property before it has been initialized will result in a crash.
 Attempting to mutate this property after it has been set will result in a crash.
 */
@propertyWrapper
struct DelayedImmutable<Value> {
  private var _value: Value?

  init() {
    _value = nil
  }

  var wrappedValue: Value {
    get {
      guard let value = _value else {
        fatalError("property accessed before being initialized")
      }
      return value
    }

    // Perform an initialization, trapping if the
    // value is already initialized.
    set {
      if _value != nil {
        fatalError("property initialized twice")
      }
      _value = newValue
    }
  }
}
