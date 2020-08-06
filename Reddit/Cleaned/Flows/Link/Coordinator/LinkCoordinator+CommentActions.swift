//
//  LinkCoordinator+CommentActions.swift
//  Reddit
//
//  Created by made2k on 2/5/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

// TODO: These are in need of deprication come iOS 13 min version
extension LinkCoordinator {
  
  func showCommentActions(model: CommentModel, sender: UIView) {
    let alert = AlertController()
    
    addEdit(alert, model: model)
    addShare(alert, model: model, view: sender)
    addReply(alert, model: model)
    addSelect(alert, model: model)
    addUser(alert, model: model)
    addRemindAction(alert, model: model)
    addFilter(alert, model: model)
    addDelete(alert, model: model)

    alert.show()
  }
  
  // MARK: - Alert Actions
  
  private func addEdit(_ alert: AlertController, model: CommentModel) {
    guard model.isUserComment else { return }
    
    let editAction = AlertAction(
      title: R.string.link.editTitle(),
      icon: R.image.icon_edit()) { [weak self] in
        self?.commentContextDidEdit(model: model)
    }
    
    alert.addAction(editAction)
  }
  
  private func addUser(_ alert: AlertController, model: CommentModel) {
    
    let userAction = AlertAction(
      title: R.string.link.authorTitle(model.author),
      icon: R.image.icon_user()) { [weak self] in
        self?.commentContextDidOpenUser(model: model)
    }
    
    alert.addAction(userAction)
  }
  
  private func addFilter(_ alert: AlertController, model: CommentModel) {
    
    let filterAction = AlertAction(title: R.string.link.filterTitle(),
                                   icon: R.image.icon_filter(),
                                   hasNext: true) { [weak self] in

      let availableSubtypes: [FilterSubtype] = [.author, .subject, .score]

      let alert = AlertController()

      for subtype in availableSubtypes {

        let subTypeAction = AlertAction(title: subtype.description, icon: nil) { [weak self] in
          self?.commentContextDidFilter(model: model, subType: subtype)
        }

        alert.addAction(subTypeAction)
      }

      alert.show()
    }
    
    alert.addAction(filterAction)
  }
  
  private func addShare(_ alert: AlertController, model: CommentModel, view: UIView) {

    let shareAction = AlertAction(
      title: R.string.link.shareTitle(),
      icon: R.image.icon_action()) { [weak self] in
        self?.commentContextDidShare(model: model, sourceView: view)
    }
    
    alert.addAction(shareAction)
  }
  
  private func addSelect(_ alert: AlertController, model: CommentModel) {
    
    let selectTextAction = AlertAction(
      title: R.string.link.selectModeTitle(),
      icon: R.image.icon_text_selection()) { [weak self] in
        self?.commentContextDidSelectText(model: model)
    }
    
    alert.addAction(selectTextAction)
  }
  
  private func addDelete(_ alert: AlertController, model: CommentModel) {

    guard model.isUserComment else { return }
    guard model.isDeleted == false else { return }
    
    let deleteAction = AlertAction(
      title: R.string.link.deleteTitle(),
      icon: R.image.icon_trash()) { [weak self] in
        self?.commentContextDidDelete(model: model)
    }
    
    alert.addAction(deleteAction)
  }
  
  private func addReply(_ alert: AlertController, model: CommentModel) {
    guard model.isDeleted == false else { return }
    guard model.archived == false else { return }
    guard AccountModel.currentAccount.value.isSignedIn else { return }
    
    let selectTextAction = AlertAction(
      title: R.string.link.replyTitle(),
      icon: R.image.icon_reply()) { [weak self] in
        self?.commentContextDidReply(model: model)
    }
    
    alert.addAction(selectTextAction)
  }
  
  private func addRemindAction(_ alert: AlertController, model: CommentModel) {
    let permalink = model.comment.permaLink
    let body = model.body
    
    let remindAction = AlertAction(title: R.string.link.remind(),
                                 icon: R.image.icon_time()) {

      ReminderTimeViewController.showReminder(type: .comment, url: permalink, body: body)
    }

    alert.addAction(remindAction)
  }
  
}
