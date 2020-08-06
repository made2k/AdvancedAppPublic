//
//  MoreCommentCellNode.swift
//  Reddit
//
//  Created by made2k on 1/29/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

class MoreCommentCellNode: CommentCellNode {
  
  override var isSelected: Bool {
    didSet {
      if isSelected {
        (loadMoreLoadingNode.view as? UIActivityIndicatorView)?.startAnimating()
        loadMoreText.alpha = 0.5

      } else {
        (loadMoreLoadingNode.view as? UIActivityIndicatorView)?.stopAnimating()
        loadMoreText.alpha = 1.0
      }

    }
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let bodyLoadingHorizontal = ASStackLayoutSpec.horizontal()
    bodyLoadingHorizontal.children = [loadMoreText, loadMoreLoadingNode]
    bodyLoadingHorizontal.spacing = 12
    bodyLoadingHorizontal.verticalAlignment = .center
    
    let bodyInset = ASInsetLayoutSpec()
    bodyInset.child = bodyLoadingHorizontal
    bodyInset.style.flexShrink = 1
    bodyInset.style.flexGrow = 1
    bodyInset.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    
    let levelSpec = ASStackLayoutSpec.horizontal()
    levelSpec.spacing = 12
    levelSpec.children = [levelIndicator, bodyInset]
    if model.level == 0 {
      levelSpec.children?.removeFirst()
    }
    
    let levelInset = ASInsetLayoutSpec()
    levelInset.insets = UIEdgeInsets(top: 10, left: 8 * CGFloat(model.level + 1), bottom: 0, right: 0)
    levelInset.child = levelSpec
    
    let seperatorInset = ASInsetLayoutSpec()
    seperatorInset.insets = levelInset.insets
    seperatorInset.child = seperator
    
    let overview = ASStackLayoutSpec.vertical()
    overview.spacing = 2
    overview.children = [levelInset, seperatorInset]
    
    return overview
  }
  
}
