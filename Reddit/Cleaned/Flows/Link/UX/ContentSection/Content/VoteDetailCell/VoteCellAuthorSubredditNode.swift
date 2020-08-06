//
//  VoteCellAuthorSubredditNode.swift
//  Reddit
//
//  Created by made2k on 1/30/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import Then

class VoteCellAuthorSubredditNode: ASDisplayNode {
  
  private let userContext: UserPreviewContextMenu?

  private let authorButtonNode = ButtonNode(weight: .bold, size: .small, color: .secondaryLabel)
  private lazy var subredditButtonNode: SubredditButtonNode = {
    return SubredditButtonNode(subreddit: model.link.subreddit, weight: .bold, size: .small, color: .secondaryLabel).then {
      $0.style.flexShrink = 1
    }
  }()

  private let byTextNode = TextNode(color: .secondaryLabel).then {
    $0.text = R.string.link.byPrefix()
  }
  private let inTextNode = TextNode(color: .secondaryLabel).then {
    $0.text = R.string.link.inString()
  }

  private let model: LinkModel

  init(linkModel: LinkModel) {
    self.model = linkModel
    
    if linkModel.link.author != "[deleted]" {
      userContext = UserPreviewContextMenu(username: linkModel.link.author)
      
    } else {
      userContext = nil
    }

    super.init()

    automaticallyManagesSubnodes = true

    authorButtonNode.title = linkModel.link.author

    authorButtonNode.tapAction = {
      LinkHandler.openRedditUser(userName: linkModel.link.author)
    }
  }
  
  override func didLoad() {
    super.didLoad()
    userContext?.register(view: authorButtonNode.view)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [byTextNode, authorButtonNode, inTextNode, subredditButtonNode]
    horizontal.alignItems = .baselineFirst
//    horizontal.alignItems = .start
    horizontal.verticalAlignment = .bottom
    return horizontal
  }

}
