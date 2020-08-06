//
//  PasscodeConfiguration.swift
//  Reddit
//
//  Created by made2k on 7/13/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import PasscodeLock

class PasscodeConfiguration: NSObject, PasscodeLockConfigurationType {
  
  let repository: PasscodeRepositoryType = PasscodeRepository.shared
  let passcodeLength: Int = 4
  var isBiometricAllowed: Bool {
    get { return Settings.passcodeUsesTouchId }
    set { Settings.passcodeUsesTouchId = newValue }
  }
  var shouldRequestTouchIDImmediately: Bool { return isBiometricAllowed }
  var maximumInccorectPasscodeAttempts: Int = 0
  
  var onViewControllerLoad: ((PasscodeLockViewController) -> Void)? = { controller in
    controller.view.backgroundColor = .systemBackground
    [controller.cancelButton, controller.touchIDButton, controller.cancelButton].forEach {
      $0?.tintColor = .systemBlue
    }
    controller.titleLabel?.textColor = .label
    controller.descriptionLabel?.textColor = .secondaryLabel
    controller.placeholders.forEach { $0.tintColor = .systemBlue }
    controller.inputButtons.forEach { $0.tintColor = .systemBlue }
  }
}
