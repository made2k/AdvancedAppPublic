//
//  Rx+UITextView.swift
//  Reddit
//
//  Created by made2k on 1/29/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UITextView {

  public var font: Binder<UIFont> {
    return Binder(self.base) { textView, font in
      textView.font = font
    }
  }

}
