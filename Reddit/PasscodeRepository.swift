//
//  PasscodeRepository.swift
//  Reddit
//
//  Created by made2k on 7/13/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import PasscodeLock

class PasscodeRepository: NSObject, PasscodeRepositoryType {
  static let shared = PasscodeRepository()
  private override init() {}

  var hasPasscode: Bool {
    return Settings.passcodeEnabled
  }

  var passcode: [String]? {
    return Settings.passcode
  }

  func savePasscode(_ passcode: [String]) {
    Settings.passcodeEnabled = true
    Settings.passcode = passcode
  }

  func deletePasscode() {
    Settings.passcodeEnabled = false
    Settings.passcode = nil
  }
}
