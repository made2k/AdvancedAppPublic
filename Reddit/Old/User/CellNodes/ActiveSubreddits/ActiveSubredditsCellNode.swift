//
//  ActiveSubredditsCellNode.swift
//  Reddit
//
//  Created by made2k on 1/27/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI
import Then
import UIKit

class ActiveSubredditsCellNode: ASCellNode {
  
  let iconImage: ASNetworkImageNode
  let nameText = TextNode(size: .micro).then {
    $0.maximumNumberOfLines = 1
  }
  let subscribersText = TextNode(size: .custom(10), color: .secondaryLabel).then {
    $0.maximumNumberOfLines = 1
  }
  
  init(subreddit: KarmaListSubreddit) {
    
    iconImage = ASNetworkImageNode()

    super.init()
    
    if let imageUrl = subreddit.icon ?? subreddit.communityIcon {
      iconImage.url = imageUrl
    } else {
      iconImage.image = UIImage.appIcon
    }
    nameText.text = subreddit.displayName
    subscribersText.text = "\(StringUtils.numberSuffix(subreddit.subscriberCount)) Subs"
    
    addSubnode(iconImage)
    addSubnode(nameText)
    addSubnode(subscribersText)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let imageSize = constrainedSize.max.height * 0.5
    iconImage.style.preferredSize = CGSize(width: imageSize, height: imageSize)
    iconImage.cornerRadius = imageSize / 2
    
    let vertical = ASStackLayoutSpec.vertical()
    vertical.horizontalAlignment = .middle
    vertical.children = [iconImage, nameText, subscribersText]
    
    let center = ASCenterLayoutSpec(horizontalPosition: .center, verticalPosition: .center, sizingOption: .minimumSize, child: vertical)
    
    return center
  }
}
