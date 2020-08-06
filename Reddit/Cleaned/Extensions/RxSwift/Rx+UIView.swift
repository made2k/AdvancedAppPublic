//
//  Rx+UIView.swift
//  Reddit
//
//  Created by made2k on 1/29/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIView {

  public var isVisible: Binder<Bool> {
    return Binder(self.base) { view, visible in
      view.isHidden = !visible
    }
  }

}

