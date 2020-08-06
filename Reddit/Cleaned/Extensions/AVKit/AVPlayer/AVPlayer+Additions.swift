//
//  AVPlayer+Additions.swift
//  Reddit
//
//  Created by made2k on 7/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AVFoundation

extension AVPlayer {

  func allowSleepDuringPlayback() {

    if #available(iOS 12.0, *) {
      preventSleepNew()
    } else {
      preventSleepLegacy()
    }

  }

  @available(iOS 12.0, *)
  private func preventSleepNew() {
    preventsDisplaySleepDuringVideoPlayback = false
  }

  private func preventSleepLegacy() {

    let obfuscatedSelectorParts = ["_prevents", "SleepDuringVideoPlayback"]
    let joinedSelector = obfuscatedSelectorParts.joined()
    let selector = NSSelectorFromString(joinedSelector)

    if responds(to: selector) {

      let obfuscatedValueParts = ["prevents", "SleepDuringVideoPlayback"]
      let value = obfuscatedValueParts.joined()

      setValue(false, forKey: value)
    }

  }

}
