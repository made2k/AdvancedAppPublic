//
//  VoteCellScoreNode.swift
//  Reddit
//
//  Created by made2k on 1/31/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import Then

class VoteCellScoreNode: ASDisplayNode {
  
  private let upvoteButton: UpvoteButtonNode
  private let downvoteButton: DownvoteButtonNode
  
  private let scoreTextNode = TextNode(color: .secondaryLabel)
  
  private let model: LinkModel
  
  private let disposeBag = DisposeBag()
  
  init(linkModel: LinkModel) {
    
    self.model = linkModel
    self.upvoteButton = UpvoteButtonNode(model: linkModel, defaultColor: .secondaryLabel).then {
      $0.style.preferredSize = CGSize(width: 25, height: 25)
    }
    self.downvoteButton = DownvoteButtonNode(model: linkModel, defaultColor: .secondaryLabel).then {
      $0.style.preferredSize = CGSize(width: 25, height: 25)
    }
    
    super.init()
    
    automaticallyManagesSubnodes = true
    
    setupBindings()
  }
  
  private func setupBindings() {
    
    model.scoreTextObserver
      .bind(to: scoreTextNode.rx.text)
      .disposed(by: disposeBag)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.spacing = 4
    horizontal.verticalAlignment = .center
    if model.link.archived {
      horizontal.children = [scoreTextNode]
      
    } else {
      horizontal.children = [upvoteButton, scoreTextNode, downvoteButton]
    }
    
    return horizontal
  }

}
