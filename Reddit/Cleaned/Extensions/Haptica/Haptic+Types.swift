//
//  Haptic+Types.swift
//  Reddit
//
//  Created by made2k on 4/5/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Haptica

extension Haptic {

  static var button: Haptic {
    return .impact(.light)
  }

  static func longPress() {
    Haptic.impact(.medium).generate()
  }

}
