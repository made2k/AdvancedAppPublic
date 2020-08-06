//
//  CommentCellNode+Layout.swift
//  Reddit
//
//  Created by made2k on 1/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension CommentCellNode {

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    if isHiddenState {
      return hiddenLayout()
    }

    let detailGildedSpec = ASStackLayoutSpec.horizontal()
    detailGildedSpec.spacing = 6
    detailGildedSpec.style.flexShrink = 1
    detailGildedSpec.children = []
    detailGildedSpec.children?.append(detailNode)
    if let gildingNode = gildingNode, gildingNode.hasBeenGilded {
      detailGildedSpec.children?.prepend(gildingNode)
    }
    detailGildedSpec.verticalAlignment = .center

    let detailSpec = ASStackLayoutSpec.horizontal()
    detailSpec.style.flexShrink = 1
    detailSpec.children = [detailGildedSpec, ASLayoutSpec.spacer()]
    if showChildren {
      detailSpec.children?.append(childrenText)
    }

    let actionSpec = ASStackLayoutSpec.horizontal()
    actionSpec.spacing = 8
    actionSpec.verticalAlignment = .center
    if showVoteButtons {
      let voteHorizontalSpec = ASStackLayoutSpec.horizontal()
      voteHorizontalSpec.children = [upvoteButton, downvoteButton]
      voteHorizontalSpec.spacing = 8

      actionSpec.children = [ASLayoutSpec.spacer(), replyButton, voteHorizontalSpec]
    }

    let actionInset = ASInsetLayoutSpec()
    actionInset.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 24)
    actionInset.child = actionSpec

    let bodySpec = ASStackLayoutSpec.vertical()
    bodySpec.spacing = 8
    bodySpec.children = [detailSpec]
    if showMessageBody {
      bodySpec.children?.append(bodyText)
    }

    let bodyInset = ASInsetLayoutSpec()
    bodyInset.style.flexShrink = 1
    bodyInset.style.flexGrow = 1
    bodyInset.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    bodyInset.child = bodySpec

    let levelSpec = ASStackLayoutSpec.horizontal()
    levelSpec.spacing = 12
    levelSpec.children = [levelIndicator, bodyInset]
    if model.level == 0 || showLevel == false {
      levelSpec.children?.removeFirst()
    }

    let levelInset = ASInsetLayoutSpec()
    let leftInset = showLevel == false ? 8 : 8 * CGFloat(model.level + 1)
    levelInset.insets = UIEdgeInsets(top: 10, left: leftInset, bottom: 0, right: 0)
    levelInset.child = levelSpec

    var cellSeparatorInset: ASInsetLayoutSpec?
    if showSeparator {
      cellSeparatorInset = ASInsetLayoutSpec()
      cellSeparatorInset?.insets = levelInset.insets
      cellSeparatorInset?.child = seperator
    }

    let overview = ASStackLayoutSpec.vertical()
    overview.spacing = 2
    overview.children = [levelInset]
    if Settings.swipeMode.value == false || Settings.swipeHidesCommentActions.value == false {
      overview.children?.append(actionInset)
    }
    if let cellSeparatorInset = cellSeparatorInset {
      overview.children?.append(cellSeparatorInset)
    }

    return overview
  }

  private func hiddenLayout() -> ASLayoutSpec {
    return ASLayoutSpec()
  }

}
