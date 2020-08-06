//
//  ObservableType+Additions.swift
//  Reddit
//
//  Created by made2k on 5/1/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxSwift

extension ObservableType {
  
  func asVoid() -> Observable<Void> {
    return self.map { _ in () }
  }
  
}
