//
//  BehaviorRelay+Additions.swift
//  Reddit
//
//  Created by made2k on 5/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxCocoa
import RxSwift

extension BehaviorRelay where Element: RangeReplaceableCollection {

  var isNotEmpty: Bool { return value.isEmpty == false }
  var isEmpty: Bool { return value.isEmpty }

  // MARK: Append

  func append(_ element: Element.Element) {
    accept(value + [element])
  }
  
  func append(contentsOf sequence: [Element.Element]) {
    accept(value + sequence)
  }

  // MARK: Remove

  func remove(at index: Element.Index) {

    var mutableValue = value
    mutableValue.remove(at: index)

    accept(mutableValue)
  }

}

