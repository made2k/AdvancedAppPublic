//
//  LinkCoordinator+LinkContentSelfTextCellDelegate.swift
//  Reddit
//
//  Created by made2k on 8/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

extension LinkCoordinator: LinkContentSelfTextCellDelegate {
  
  
  func selfTextDidSelectText(_ model: LinkModel) {
    guard let controller = controller else { return }
    TextSelectionCoordinator(text: model.link.selftext ?? "", presenting: controller).start()
  }
  
  func selfTextDidSelectReply(_ model: LinkModel) {
    let coordinator = CommentCreateCoordinator(presenting: self.navigation,
                                               replyName: model.link.name,
                                               replyHtml: model.link.selftextHtml,
                                               delegate: self)
    self.childCoordinator = coordinator
    
    coordinator.start()
  }
  
  // MARK: - Legacy Calls (Pre iOS 13)
  
  func selfTextWasLongPressed(_ model: LinkModel) {
    
    let alert = AlertController()
    
    let selectAction = AlertAction(
      title: R.string.link.selectText(),
      icon: R.image.icon_text_selection()) {
        self.selfTextDidSelectText(model)
    }

    alert.addAction(selectAction)
    
    if AccountModel.currentAccount.value.isSignedIn && model.link.archived == false {
      
      let addCommentAction = AlertAction(
        title: R.string.link.addComment(),
        icon: R.image.icon_reply()) { [unowned self] in
          self.selfTextDidSelectReply(model)
      }

      alert.addAction(addCommentAction)
    }

    alert.show()
  }

}
