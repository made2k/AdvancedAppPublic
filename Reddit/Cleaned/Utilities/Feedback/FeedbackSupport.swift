//
//  FeedbackSupport.swift
//  Reddit
//
//  Created by made2k on 1/14/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

enum FeedbackSupport: Int {

  case notSupported
  case partiallySupported
  case fullySupported

  static let supportType: FeedbackSupport = {
    // https://stackoverflow.com/questions/41444274/how-to-check-if-haptic-engine-uifeedbackgenerator-is-supported
    let supportInt = UIDevice.current.value(forKey: "_feedbackSupportLevel") as? Int ?? 2
    return FeedbackSupport(rawValue: supportInt) ?? .fullySupported
  }()

  static func isSupported() -> Bool {
    return supportType == .fullySupported
  }

}
