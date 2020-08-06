//
//  CommentLoadingCellNode.swift
//  Reddit
//
//  Created by made2k on 11/10/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit
import Then

/**
 An ASCellNode that shows only a UIActivityView that animates
 when in the visible state
 */
class LoadingActivityCellNode: ASCellNode {

  private let activityNode = ActivityIndicatorNode(style: .medium)
  
  override init() {
    super.init()

    automaticallyManagesSubnodes = true
    selectionStyle = .none

  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let activityCenter = ASCenterLayoutSpec()
    activityCenter.horizontalPosition = .center
    activityCenter.verticalPosition = .center
    activityCenter.child = activityNode

    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 32, left: 16, bottom: 32, right: 16)
    inset.child = activityCenter
    
    return inset
  }
  
}
