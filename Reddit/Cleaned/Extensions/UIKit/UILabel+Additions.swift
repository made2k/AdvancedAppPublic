//
//  UILabel+Additions.swift
//  Reddit
//
//  Created by made2k on 6/18/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension UILabel {

  private struct AssociatedKeys {
    static var disposeBag: UInt8 = 0
    static var observer: UInt8 = 1
  }
  
  private var disposeBag: DisposeBag {
    get {
      if let existing = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag {
        return existing
      }

      let disposeBag = DisposeBag()
      self.disposeBag = disposeBag
      
      return disposeBag
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  var fontObserver: Observable<UIFont>? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.observer) as? Observable<UIFont>
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.observer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      
      disposeBag = DisposeBag()
      
      newValue?
        .bind(to: rx.font)
        .disposed(by: disposeBag)
      
    }
  }
  

}
