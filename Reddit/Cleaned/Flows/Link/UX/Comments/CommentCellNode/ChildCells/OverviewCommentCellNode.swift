//
//  OverviewCommentCellNode.swift
//  Reddit
//
//  Created by made2k on 11/16/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

/// The overview comment cell is a comment cell showin in overview.
/// It doesn't have vote buttons or the bottom seperator.
class OverviewCommentCellNode: CommentCellNode {
  
  override var showLevel: Bool {
    get { return false }
    set { }
  }
  override var showVoteButtons: Bool {
    get { return false }
    set { }
  }
  override var showSeparator: Bool {
    get { return false }
    set { }
  }

  init(model: CommentModelType) {
    super.init(model: model, link: nil)
    backgroundColor = .secondarySystemGroupedBackground
  }
  
}
