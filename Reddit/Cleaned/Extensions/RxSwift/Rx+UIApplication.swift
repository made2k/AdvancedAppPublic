//
//  Rx+UIApplication.swift
//  Reddit
//
//  Created by made2k on 2/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIApplication {

  var isIdleTimerDisabled: Binder<Bool> {
    return Binder(base) { application, disabled in
      application.isIdleTimerDisabled = disabled
    }
  }

}

