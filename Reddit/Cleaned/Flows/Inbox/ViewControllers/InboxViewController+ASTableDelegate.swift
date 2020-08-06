//
//  InboxViewController+ASTableDelegate.swift
//  Reddit
//
//  Created by made2k on 2/4/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import AsyncDisplayKit

extension InboxViewController: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let message: MessageModel = model.messages[indexPath.row]
    delegate.didSelectMessage(message: message)
  }

}
