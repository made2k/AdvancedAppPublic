//
//  Rx+UILabel.swift
//  Reddit
//
//  Created by made2k on 6/18/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UILabel {
  
  public var font: Binder<UIFont> {
    return Binder(self.base) { label, font in
      label.font = font
    }
  }
  
}

