//
//  ProfileOverviewCellNode.swift
//  Reddit
//
//  Created by made2k on 1/27/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI

class ProfileOverviewCellNode: ASCellNode {
  
  let avatarImageNode = ASNetworkImageNode().then {
    $0.style.preferredSize = CGSize(width: 75, height: 75)
    $0.cornerRadius = 5
  }
  let nameLabel = TextNode().then {
    $0.textColor = .label
    $0.font = Settings.fontSettings.fontValue.bold
  }
  let linkKarmaLabel = TextNode().then {
    $0.textColor = .secondaryLabel
    $0.font = Settings.fontSettings.fontValue
  }
  let commentKarmaLabel = TextNode().then {
    $0.textColor = .secondaryLabel
    $0.font = Settings.fontSettings.fontValue
  }
  let birthdayNode = TextNode().then {
    $0.textColor = .secondaryLabel
    $0.font = Settings.fontSettings.fontValue
  }
  
  init(user: User) {

    super.init()

    automaticallyManagesSubnodes = true
    selectionStyle = .none
    backgroundColor = .secondarySystemGroupedBackground

    avatarImageNode.url = user.icon
    nameLabel.text = "u/\(user.name)"
    linkKarmaLabel.text = "Link karma: \(StringUtils.numberSuffix(user.linkKarma))"
    commentKarmaLabel.text = "Comment karma: \(StringUtils.numberSuffix(user.commentKarma))"

    let formatter = DateFormatter()
    formatter.dateStyle = .short
    birthdayNode.text = "Redditor since: \(formatter.string(from: user.created))"
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let vertical = ASStackLayoutSpec.vertical()
    vertical.spacing = 2
    vertical.horizontalAlignment = .right
    vertical.children = [nameLabel, linkKarmaLabel, commentKarmaLabel, birthdayNode]
    
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.justifyContent = .spaceBetween
    horizontal.children = [avatarImageNode, vertical]

    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    inset.child = horizontal
    
    return inset
  }

}
