//
//  Rx+UIControl.swift
//  Reddit
//
//  Created by made2k on 5/1/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIControl {

  public var isDisabled: Binder<Bool> {
    return Binder(self.base) { control, value in
      control.isEnabled = !value
    }
  }

}
