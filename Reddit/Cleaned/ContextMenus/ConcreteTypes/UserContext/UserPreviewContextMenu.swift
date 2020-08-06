//
//  UserPreviewContextMenu.swift
//  Reddit
//
//  Created by made2k on 8/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

class UserPreviewContextMenu: ContextMenu {
  
  private let username: String
  
  override var previewProvider: UIContextMenuContentPreviewProvider? {
    return { [unowned self] in UserPreviewViewController(username: self.username) }
  }
  
  init(username: String) {
    self.username = username
  }
  
  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
    animator.addCompletion { [weak self] in
      guard let self = self else { return }
      LinkHandler.openRedditUser(userName: self.username)
    }
  }

}
