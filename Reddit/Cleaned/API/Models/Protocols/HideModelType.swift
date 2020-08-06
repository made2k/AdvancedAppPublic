//
//  HideModelType.swift
//  Reddit
//
//  Created by made2k on 9/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RxCocoa

protocol HideModelType: ViewModel {

  var name: String { get }
  var hidden: BehaviorRelay<Bool> { get }

}

extension HideModelType {

  func setHidden(_ hidden: Bool) -> Promise<Void> {

    let existingValue = self.hidden.value

    return firstly {
      api.session.setHidden(hidden: hidden, name: name)

    }.done {
      self.hidden.accept(hidden)

    }.recover { error -> Promise<Void> in
      self.hidden.accept(existingValue)
      throw error
    }

  }

}
