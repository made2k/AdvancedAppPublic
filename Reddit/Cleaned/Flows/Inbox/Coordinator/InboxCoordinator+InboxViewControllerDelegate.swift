//
//  InboxCoordinator+InboxViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 2/5/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RedditAPI
import PromiseKit
import UIKit

extension InboxCoordinator: InboxViewControllerDelegate {

  // MARK: - Protocol

  func didTapToChangeInboxType() {
    showInboxOptions()
  }

  func didTapToComposeNewMessage() {
    let controller: UIViewController = ComposeMessageViewController(model: model)

    let navigation = NavigationController(controllers: controller)
    navigation.modalPresentationStyle = UIModalPresentationStyle.formSheet

    if #available(iOS 13.0, *) {
      navigation.isModalInPresentation = true
    }

    self.navigation.present(navigation)
  }

  func didSelectMessage(message: MessageModel) {
    if let url = message.message.context, message.message.kind == .comment {
      LinkHandler.handleUrl(url)

    } else if message.message.kind == .message {
      openReply(with: message)
    }

  }

  func showMessageOptions(for message: MessageModel, at indexPath: IndexPath) {

    if message.message.kind == .comment {
      showCommentMessageOptions(model: message, indexPath: indexPath)

    } else {
      showDirectMessageOptions(model: message, indexPath: indexPath)
    }

  }

  func openReply(with model: MessageModel) {
    let coordinator = MessageCreateCoordinator(presenting: navigation,
                                               replyName: model.message.name,
                                               replyHtml: model.message.bodyHtml)
    childCoordinator = coordinator
    coordinator.start()
  }

  // MARK: - Internal

  private func showInboxOptions() {

    let applicableOptions: [InboxType] = InboxType.allCases
      .filter { $0 != model.inboxType }

    let alert = AlertController()

    for type in applicableOptions {

      let action: AlertAction = AlertAction(title: type.title, icon: type.icon) { [model] in
        model.setType(type)
      }

      alert.addAction(action)

    }

    alert.show()
  }

  private func showCommentMessageOptions(model: MessageModel, indexPath: IndexPath) {

    let block = blockAction(for: model, indexPath: indexPath)
    let read = readToggleAction(for: model)

    let alert: AlertController = AlertController()
    alert.addAction(block)
    alert.addAction(read)

    alert.show()
  }

  private func showDirectMessageOptions(model: MessageModel, indexPath: IndexPath) {

    let alert: AlertController = AlertController()

    let delete = deleteAction(for: model, indexPath: indexPath)
    alert.addAction(delete)

    if model.message.author != AccountModel.currentAccount.value.username {
      let block = blockAction(for: model, indexPath: indexPath)
      alert.addAction(block)
    }

    let read = readToggleAction(for: model)
    alert.addAction(read)

    alert.show()
  }

  private func deleteMessage(at indexPath: IndexPath) {
    model.delete(at: indexPath.row)
    controller?.deleteRow(at: indexPath)
  }

}

// MARK: - Message Actions

extension InboxCoordinator {

  private func blockAction(for model: MessageModel, indexPath: IndexPath) -> AlertAction {

     return AlertAction(title: "Block User", icon: nil) { [unowned self] in

       firstly {
         model.block()

       }.done {
         self.deleteMessage(at: indexPath)

       }.catch { _ in
         Overlay.shared.flashErrorOverlay("There was a problem blocking this user")
       }

     }

   }

   private func readToggleAction(for model: MessageModel) -> AlertAction {
     let readTitle = model.read ? "Mark Unread" : "Mark Read"
     let readToggleAction = AlertAction(title: readTitle, icon: nil) {

       if model.read {
         model.markUnread().cauterize()

       } else {
         model.markRead().cauterize()
       }

     }

     return readToggleAction
   }

   private func deleteAction(for model: MessageModel, indexPath: IndexPath) -> AlertAction {

     return AlertAction(title: "Delete", icon: nil) { [unowned self] in

       firstly {
         model.delete()

       }.done {
         self.deleteMessage(at: indexPath)

       }.catch { _ in
         Overlay.shared.flashErrorOverlay("There was a problem deleting this message")
       }

     }

   }

}
