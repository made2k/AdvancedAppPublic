//
//  LiveCommentsCoordinator+ASTableDelegate.swift
//  Reddit
//
//  Created by made2k on 2/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension LiveCommentsCoordinator: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let comment = model.comments[indexPath.row]

    if comment.name == replyingComment.value?.name {
      replyingComment.accept(nil)
      // TODO: I don't think this is needed
      tableNode.nodeForRow(at: indexPath)?.isSelected = false

    } else {
      replyingComment.accept(comment)
    }

  }

}
