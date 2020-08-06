//
//  InboxViewController+MessageCellNodeDelegate.swift
//  Reddit
//
//  Created by made2k on 2/5/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Foundation

extension InboxViewController: MessageCellNodeDelegate {

  func didSwipeToReply(model: MessageModel) {
    delegate.openReply(with: model)
  }

  func messageCellShowActions(for model: MessageModel, indexPath: IndexPath) {
    delegate.showMessageOptions(for: model, at: indexPath)
  }

}
