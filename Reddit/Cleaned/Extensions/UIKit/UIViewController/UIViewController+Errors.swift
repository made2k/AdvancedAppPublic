//
//  UIViewController+Errors.swift
//  Reddit
//
//  Created by made2k on 5/31/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension UIViewController {
  
  private struct AssociatedKeys {
    static var inAppPurchaseCoordinator: UInt8 = 0
  }
  
  private var inAppPurchaseCoordinator: Coordinator? {
    get {
      return objc_getAssociatedObject(self,
                                      &AssociatedKeys.inAppPurchaseCoordinator) as? Coordinator
    }
    set {
      objc_setAssociatedObject(self,
                               &AssociatedKeys.inAppPurchaseCoordinator,
                               newValue,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  
  
  // MARK: - Generic Error Handling
  
  func handle(error: Error) {
    
    switch error {
      // TODO: Remove this
    case OldAPIError.notSignedIn: showSignInError()
    default: Toast.show(R.string.uiKitExtensions.genericErrorToast(), duration: 2)
    }
    
  }
  
  func presentGenericError(error: Error, text: String? = nil) {
    #if DEBUG
    let text = text ?? error.localizedDescription
    #else
    let text = text ?? R.string.uiKitExtensions.genericErrorMessage()
    #endif
    
    let alert = UIAlertController(title: nil,
                                  message: text,
                                  preferredStyle: .alert)
    alert.addAction(title: R.string.uiKitExtensions.okButton())

    present(alert)
  }
  
  /**
   Shows an alert with the given title and message with a single
   Okay action that does not have a handler.
   */
  func showAlert(title: String? = nil, message: String) {
    
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)

    alert.addAction(title: R.string.uiKitExtensions.okButton())

    present(alert)
  }
  
  // MARK: - Specalized Errors
  
  // Sign In Error
  
  func showSignInError() {
    
    let alert = UIAlertController(title: R.string.uiKitExtensions.notSignedIn(),
                                  message: R.string.uiKitExtensions.notSignedInMessage(),
                                  preferredStyle: .alert)

    alert.addAction(title: R.string.uiKitExtensions.cancelButton())
    alert.addAction(title: R.string.uiKitExtensions.signInButton()) { [unowned self] _ in
      let vc = AccountsViewController.fromStoryboard()
      self.show(vc, sender: self)
    }

    present(alert)
  }
    
  // No Photo Access
  
  func handleNoPhotoAccess() {
    
    let alert = UIAlertController(title: R.string.uiKitExtensions.permissionNeeded(),
                                  message: R.string.uiKitExtensions.photoPermissionMessage(),
                                  preferredStyle: .alert)

    alert.addAction(title: R.string.uiKitExtensions.cancelButton())
    alert.addAction(title: R.string.uiKitExtensions.openSettingsButton()) { _ in
      UIApplication.openApplicationSettings()
    }

    present(alert)
  }
  
}
