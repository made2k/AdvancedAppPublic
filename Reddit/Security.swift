//
//  Security.swift
//  Reddit
//
//  Created by made2k on 8/15/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation
import LocalAuthentication

class Security: NSObject {

  static let shared = Security()

  let context = LAContext()

  var hasBiometrics: Bool {
    var error: NSError?
    context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

    if #available(iOS 11.2, *) {
      return context.biometryType != .none && error == nil

    } else {
      return error == nil
    }
  }

  var hasFaceId: Bool {
    return context.biometryType == .faceID
  }

  private override init() {
    // Need initial set
    context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }
}
