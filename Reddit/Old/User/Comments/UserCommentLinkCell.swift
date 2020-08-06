//
//  UserCommentLinkCell.swift
//  Reddit
//
//  Created by made2k on 6/12/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI

class UserCommentLinkCell: ASCellNode {
  
  private let paddingNode = ASDisplayNode()
  
  private let titleNode = TextNode(weight: .bold, size: .large)
  private let authorNode = TextNode(color: .secondaryLabel)
  private let subredditNode = TextNode()

  private let comment: Comment
  
  init(comment: Comment) {
    self.comment = comment

    super.init()
    automaticallyManagesSubnodes = true

    selectionStyle = .none
    
    paddingNode.style.height = ASDimension(unit: .points, value: 12)
    paddingNode.backgroundColor = .systemGroupedBackground

    backgroundColor = .secondarySystemGroupedBackground
    
    titleNode.text = comment.linkTitle
    
    authorNode.text = comment.linkAuthor
    if let subreddit = comment.subreddit {
      subredditNode.text = "r/\(subreddit)"
    }
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let authorSubredditStack = ASStackLayoutSpec.horizontal()
    authorSubredditStack.spacing = 12
    authorSubredditStack.children = [authorNode, subredditNode]
    
    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.children = [titleNode, authorSubredditStack]
    
    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    inset.child = verticalSpec
    
    let paddingVertical = ASStackLayoutSpec.vertical()
    paddingVertical.children = [paddingNode, inset]
    
    return paddingVertical
  }
  
}
