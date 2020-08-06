//
//  Rx+UIBarButtonItem.swift
//  Reddit
//
//  Created by made2k on 1/31/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIBarButtonItem {

  public var image: Binder<UIImage?> {
    return Binder(self.base) { barButtonItem, image in
      barButtonItem.image = image
    }
  }

}
