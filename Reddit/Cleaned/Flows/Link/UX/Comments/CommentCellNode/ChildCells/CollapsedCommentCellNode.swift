//
//  CollapsedCommentCellNode.swift
//  Reddit
//
//  Created by made2k on 1/29/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

class CollapsedCommentCellNode: CommentCellNode {

  override var showChildren: Bool {
    get { return true }
    set { }
  }
  override var showMessageBody: Bool {
    get { return false }
    set { }
  }
  override var showVoteButtons: Bool {
    get { return false }
    set { }
  }
  
  override func didLoad() {
    super.didLoad()
    detailNode?.isUserInteractionEnabled = false
  }
  
}
