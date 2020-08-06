//
//  TitleFirstPreviewCellNode.swift
//  Reddit
//
//  Created by made2k on 1/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

final class TitleFirstPreviewCellNode: PreviewListingsCellNode {

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let innerContentSpec = ASStackLayoutSpec.vertical()
    innerContentSpec.children = [domainTextNode, bottomDetailSpec]
    innerContentSpec.spacing = 12
    innerContentSpec.style.flexGrow = 1

    let contentHorizontal = ASStackLayoutSpec.horizontal()
    contentHorizontal.spacing = 8
    contentHorizontal.verticalAlignment = .top

    if Settings.thumbnailSide.value == .left {
      contentHorizontal.children = [innerContentSpec, voteButtonSpec]

    } else {
      contentHorizontal.children = [voteButtonSpec, innerContentSpec]
    }

    let contentVerticalSpec = ASStackLayoutSpec.vertical()
    contentVerticalSpec.children = [contentHorizontal]
    contentVerticalSpec.spacing = 8

    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = contentVerticalSpec
    insetSpec.insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    let titleNSFWSpec = ASStackLayoutSpec.vertical()
    titleNSFWSpec.spacing = 8
    titleNSFWSpec.children = [titleTextNode]
    if let flairSpec = nsfwFlairSpec {
      titleNSFWSpec.children?.append(flairSpec)
    }

    let titleInsetSpec = ASInsetLayoutSpec()
    titleInsetSpec.child = titleNSFWSpec
    titleInsetSpec.insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    let previewVertical = ASStackLayoutSpec.vertical()
    previewVertical.children = [titleInsetSpec, previewNode, insetSpec, paddingNode]

    return previewVertical
  }

}
