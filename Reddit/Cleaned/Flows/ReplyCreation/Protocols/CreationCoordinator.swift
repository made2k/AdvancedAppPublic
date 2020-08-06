//
//  CreationCoordinator.swift
//  Reddit
//
//  Created by made2k on 9/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

protocol CreationCoordinator: Coordinator, CommentCreateViewControllerDelegate {
  
  var presentingController: UIViewController { get }
  
  var controllerAutoFill: String? { get }
  var controllerParentHTML: String? { get }
  var controllerTitle: String { get }
}

extension CreationCoordinator {
  
  func start() {
    
    let controller = CommentCreateViewController(autofill: controllerAutoFill,
                                                 parentHtml: controllerParentHTML,
                                                 delegate: self)

    let navigation = NavigationController(controllers: controller)
    navigation.modalPresentationStyle = .formSheet
    if #available(iOS 13.0, *) { navigation.isModalInPresentation = true }

    controller.title = controllerTitle

    presentingController.present(navigation)
  }
  
}

extension CreationCoordinator {
  
  func cancelButtonPressed(_ text: String?) {
    if text.isNilOrEmpty {
      clearAndDismiss()
      
    } else {
      showCancelWarning()
    }
  }
  
  private func showCancelWarning() {
    
    let alert = UIAlertController(title: R.string.replyCreate.cancelCommentAlertTitle(),
                                  message: R.string.replyCreate.cancelCommentAlertMessage(),
                                  preferredStyle: .alert)

    let noAction = UIAlertAction(title: R.string.replyCreate.cancelCommentNo(),
                                 style: .default,
                                 handler: nil)
    alert.addAction(noAction)


    let yesAction = UIAlertAction(
      title: R.string.replyCreate.cancelCommentYes(),
      style: .destructive) { [unowned self] _ in
        self.clearAndDismiss()
    }
    alert.addAction(yesAction)
    
    presentingController.presentedViewController?.present(alert)
  }
  
  func clearAndDismiss() {
    AutoSaveManager.shared.clear()
    self.presentingController.presentedViewController?.dismiss()
  }

}
