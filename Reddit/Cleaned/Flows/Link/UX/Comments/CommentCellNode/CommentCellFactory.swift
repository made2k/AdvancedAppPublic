//
//  CommentCellFactory.swift
//  Reddit
//
//  Created by made2k on 1/29/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

struct CommentCellFactory {
  
  static func cell(for model: CommentModelType, link: Link?, delegate: CommentContextMenuDelegate?) -> CommentCellNode {

    if model.hidden {
      return HiddenCommentCellNode(model: model, link: link, delegate: nil)
    }
    
    if let commentModel = model as? CommentModel {
      if commentModel.collapsed.value {
        return CollapsedCommentCellNode(model: commentModel, link: link, delegate: nil)
      }
      
      if commentModel.archived {
        return ArchivedCommentCellNode(model: commentModel, link: link, delegate: delegate)
      }
      
      return CommentCellNode(model: commentModel, link: link, delegate: delegate)
    }
    
    if model is MoreModel {
      return MoreCommentCellNode(model: model, link: link, delegate: nil)
    }
    
    fatalError("unexpected comment type")
  }
  
}
