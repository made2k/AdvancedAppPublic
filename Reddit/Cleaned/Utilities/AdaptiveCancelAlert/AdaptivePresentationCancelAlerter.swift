//
//  AdaptivePresentationCancelAlerter.swift
//  Reddit
//
//  Created by made2k on 1/31/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import UIKit

/**
 An object used to present an alert to a user when they
 attempt to drag to dismiss a controller.

 - Important:
 The UIAdaptivePresentationControllerDelegate of
 the controller needs to be set to this class.
 */
final class AdaptivePresentationCancelAlerter: NSObject, UIAdaptivePresentationControllerDelegate {

  private weak var dismissingController: UIViewController?
  private let cancelAction: (() -> Void)?
  private let dismissEvaluation: (() -> Bool)?

  private let customTitle: String?
  private let customMessage: String?

  init(dismissing: UIViewController,
       cancelAction: (() -> Void)? = nil,
       dismissEvaluation: (() -> Bool)? = nil,
       title: String? = nil,
       message: String? = nil) {

    self.dismissingController = dismissing
    self.cancelAction = cancelAction
    self.dismissEvaluation = dismissEvaluation

    self.customTitle = title
    self.customMessage = message
  }

  func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
    guard let controller = dismissingController else { return }

    let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in

      if let cancelAction = self?.cancelAction {
        cancelAction()
        return
      }

      controller.dismiss()
    }

    let noAction = UIAlertAction(title: "No", style: .default, handler: nil)

    let title: String? = customTitle
    let message: String = customMessage ?? "Are you sure you want to cancel?"

    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(noAction)
    alert.addAction(yesAction)

    controller.present(alert)
  }

  func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
    guard let evaluation = dismissEvaluation else {
      return true
    }

    return evaluation()
  }

}
