//
//  InboxViewController+ASTableDataSource.swift
//  Reddit
//
//  Created by made2k on 2/4/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import AsyncDisplayKit

extension InboxViewController: ASTableDataSource {

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return model.messages.count
  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

    let message: MessageModel = model.messages[indexPath.row]

    return { [unowned self] in
      return MessageCellNode(model: message, delegate: self)
    }

  }

}
