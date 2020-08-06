//
//  Rx+UIScreen.swift
//  Reddit
//
//  Created by made2k on 2/18/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxSwift
import UIKit

extension Reactive where Base: UIScreen {

  var brightness: Observable<CGFloat> {

    let notification = UIScreen.brightnessDidChangeNotification

    return NotificationCenter.default.rx.notification(notification)
      .map { $0.object as? UIScreen }
      .filterNil()
      .map { $0.brightness }
      .startWith(UIScreen.main.brightness)

  }

}
