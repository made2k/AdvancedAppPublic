//
//  ObservableType+Additions.swift
//  Reddit
//
//  Created by made2k on 12/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RxOptional
import RxSwift

extension ObservableType {
  
  func asVoid() -> Observable<Void> {
    return self.map { _ in () }
  }
  
  func withPrevious(startWith first: Element) -> Observable<(Element, Element)> {
    return scan((first, first)) { ($0.1, $1) }.skip(1)
  }
  
}

extension Observable where Element: Collection {

  func replaceEmptyWithNil() -> Observable<Optional<Element>> {

    return self.flatMap { element -> Observable<Optional<Element>> in

      if element.isEmpty {
        return Observable<Optional<Element>>.just(nil)
      }

      return Observable<Optional<Element>>.just(element)
    }

  }

}

extension ObservableType where Element: OptionalType {

  func isNil() -> Observable<Bool> {

    return map { (optional: Element) -> Bool in
      return optional.value == nil
    }

  }

  func isNotNil() -> Observable<Bool> {

    return isNil().map { (isNil: Bool) -> Bool in
      return isNil == false
    }

  }

}

