//
//  ArchivedCommentCellNode.swift
//  Reddit
//
//  Created by made2k on 1/29/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

class ArchivedCommentCellNode: CommentCellNode {
  
  override var showVoteButtons: Bool {
    get { return false }
    set { }
  }
  
}
