//
//  Rx+NotificationCenter.swift
//  Reddit
//
//  Created by made2k on 5/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import class Foundation.NotificationCenter
import struct Foundation.Notification
import RxSwift

extension Reactive where Base: NotificationCenter {

  var fontDidChange: Observable<UIFont> {
    notification(.fontSettingsDidChange)
      .map(\.object)
      .map { $0 as? UIFont }
      .filterNil()
  }

  var fontChangeInitial: Observable<UIFont> {
    return fontDidChange
      .startWith(Settings.fontSettings.fontValue)
  }
  
}
