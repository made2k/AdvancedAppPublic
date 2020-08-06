//
//  TrophyCellNode.swift
//  Reddit
//
//  Created by made2k on 1/27/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI

class TrophyCellNode: ASCellNode {
  
  let trophyImage: ASNetworkImageNode
  let nameText = TextNode(size: .micro)
  
  init(trophy: Trophy) {
    
    trophyImage = ASNetworkImageNode()
    
    super.init()
    
    trophyImage.url = trophy.icon70
    nameText.text = trophy.name
    
    
    addSubnode(trophyImage)
    addSubnode(nameText)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let imageSize = constrainedSize.max.height * 0.6
    trophyImage.style.preferredSize = CGSize(width: imageSize, height: imageSize)

    let vertical = ASStackLayoutSpec.vertical()
    vertical.horizontalAlignment = .middle
    vertical.children = [trophyImage, nameText]
    
    let center = ASCenterLayoutSpec(horizontalPosition: .center, verticalPosition: .center, sizingOption: .minimumSize, child: vertical)
    
    return center    
  }
}
