//
//  LinkCoordinator+PostActions.swift
//  Reddit
//
//  Created by made2k on 1/13/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import UIKit

extension LinkCoordinator {

  private var isSignedIn: Bool {
    return AccountModel.currentAccount.value.isSignedIn
  }

  func showPostActions(sender: UIView) {
    let alert = AlertController()

    addShareAction(alert, view: sender)
    addEditAction(alert)
    addCommentAction(alert)
    addLiveAction(alert)
    addSaveAction(alert)
    addRemindAction(alert)
    addHideAction(alert)

    alert.show()
  }

  private func addShareAction(_ alert: AlertController, view: UIView) {

    let shareAction = AlertAction(title: R.string.link.shareTitle(),
                                  icon: R.image.icon_action(),
                                  hasNext: true) { [unowned self] in

      self.showShareActions(view: view)
    }

    alert.addAction(shareAction)
  }

  private func addEditAction(_ alert: AlertController) {
    guard let account = AccountModel.currentAccount.value.account else { return }
    guard let model = model else { return }
    guard model.link.archived == false else { return }
    guard model.link.author ~== account.userName else { return }
    guard model.linkType == .selfText else { return }
    guard let controller = controller else { return }

    let addAction = AlertAction(
      title: R.string.link.editPost(),
      icon: R.image.icon_edit()) { [unowned self] in

        let coordinator = LinkEditCoordinator(
          presenting: controller,
          editingLink: model,
          delegate: self
        )
        self.childCoordinator = coordinator
        coordinator.start()
    }

    alert.addAction(addAction)

  }

  private func addCommentAction(_ alert: AlertController) {

    guard isSignedIn else { return }
    guard let model = model else { return }
    guard model.link.archived == false else { return }
    guard let controller = controller else { return }

    let addAction = AlertAction(title: R.string.link.addComment(),
                                icon: R.image.icon_reply()) { [unowned self] in

      let coordinator = CommentCreateCoordinator(presenting: controller,
                                                 replyName: model.link.name,
                                                 replyHtml: model.link.selftextHtml,
                                                 delegate: self)
      self.childCoordinator = coordinator

      coordinator.start()
    }

    alert.addAction(addAction)

  }

  private func addLiveAction(_ alert: AlertController) {

    guard let model = model else { return }
    guard model.link.archived == false else { return }
    guard let controller = self.controller else { return }

    let liveAction = AlertAction(title: R.string.link.liveComments(),
                                 icon: R.image.icon_live()) {

      LiveCommentsCoordinator(presenting: controller, linkModel: model).start()
    }

    alert.addAction(liveAction)
  }

  private func addSaveAction(_ alert: AlertController) {
    guard isSignedIn else { return }
    guard let model = model else { return }

    let saveText = model.saved.value ? R.string.link.unsave() : R.string.link.save()
    let saveIcon = model.saved.value ? R.image.icon_save_fill() : R.image.icon_save_empty()

    let saveAction = AlertAction(title: saveText, icon: saveIcon) { [unowned self] in

      firstly {
        model.setSaved(!model.saved.value)

      }.catch {
        self.controller?.handle(error: $0)
      }
    }

    alert.addAction(saveAction)
  }

  private func addHideAction(_ alert: AlertController) {
    guard isSignedIn else { return }
    guard let model = model else { return }

    let hideText = model.hidden.value ? R.string.link.show() : R.string.link.hide()
    let hideIcon = model.hidden.value ? R.image.icon_hide() : R.image.icon_hidden()

    let hideAction = AlertAction(title: hideText, icon: hideIcon) { [unowned self] in

      firstly {
        model.setHidden(!model.hidden.value)

      }.catch {
        self.controller?.handle(error: $0)
      }
    }

    alert.addAction(hideAction)
  }
  
  private func addRemindAction(_ alert: AlertController) {
    guard let permalink = model?.link.permalink else { return }
    guard let body = model?.link.title else { return }
    
    let remindAction = AlertAction(title: R.string.link.remind(),
                                 icon: R.image.icon_time()) {

      ReminderTimeViewController.showReminder(type: .link, url: permalink, body: body)
    }

    alert.addAction(remindAction)
    
  }
}
