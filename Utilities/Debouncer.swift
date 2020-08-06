//
//  Debouncer.swift
//  Utilities
//
//  Created by made2k on 11/10/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation

public class Debouncer: NSObject {
  var callback: (() -> ())
  var delay: Double
  weak var timer: Timer?

  public init(delay: Double, callback: @escaping (() -> ())) {
    self.delay = delay
    self.callback = callback
  }

  public func call() {
    timer?.invalidate()
    let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(Debouncer.fireNow), userInfo: nil, repeats: false)
    timer = nextTimer
  }

  @objc private func fireNow() {
    self.callback()
  }
}
