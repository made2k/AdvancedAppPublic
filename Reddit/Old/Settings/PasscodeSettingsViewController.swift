//
//  PasscodeSettingsViewController.swift
//  Reddit
//
//  Created by made2k on 11/5/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import Eureka
import PasscodeLock
import LocalAuthentication

class PasscodeSettingsViewController: SettingsBaseViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Passcode"
    
    form +++ Section("Passcode")
      <<< SwitchRow("passcode") { row in
        row.title = "Passcode"
        row.value = Settings.passcodeEnabled
        
        }.onChange { row in
          
          let config = PasscodeConfiguration()
          let passcodeVC: PasscodeLockViewController?
          
          let value: Bool = row.value ?? false
          
          if value && !Settings.passcodeEnabled {
            passcodeVC = PasscodeLockViewController(state: .setPasscode, configuration: config)
            passcodeVC?.successCallback = { _ in
              Settings.passcodeEnabled = true
            }
            
          } else if !value && Settings.passcodeEnabled {
            passcodeVC = PasscodeLockViewController(state: .removePasscode, configuration: config)
            passcodeVC?.successCallback = { lock in
              Settings.passcodeEnabled = false
              lock.repository.deletePasscode()
            }
            
          } else {
            passcodeVC = nil
          }
          
          passcodeVC?.dismissCompletionCallback = {
            // TODO: This is fragile
            let deadlineTime = DispatchTime.now() + .milliseconds(400)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
              if let value = row.value, value != Settings.passcodeEnabled {
                row.value = !value
                row.cell.switchControl.setOn(!value, animated: true)
              }
            }
          }
          
          if let controller = passcodeVC {
            controller.modalPresentationStyle = .pageSheet
            if #available(iOS 13, *) {
              controller.isModalInPresentation = true
            }
            self.present(controller)
          }
      }
      <<< SwitchRow() { row in
        row.title = Security.shared.hasFaceId ? "Use Face ID" : "Use Touch ID"
        row.value = Settings.passcodeUsesTouchId
        row.hidden = Condition.function(["passcode"], { form in
          let passcodeValue = ((form.rowBy(tag: "passcode") as? SwitchRow)?.value ?? false)
          return passcodeValue == false || !Security.shared.hasBiometrics
        })
        
        }.onChange { row in
          let value: Bool = row.value ?? false
          Settings.passcodeUsesTouchId = value
    }
    
  }
  
  
}
