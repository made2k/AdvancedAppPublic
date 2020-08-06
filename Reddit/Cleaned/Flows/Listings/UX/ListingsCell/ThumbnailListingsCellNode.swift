//
//  ThumbnailListingsCellNode.swift
//  Reddit
//
//  Created by made2k on 1/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Logging

final class ThumbnailListingsCellNode: ListingsCellNode {

  private(set) lazy var thumbnailNode: ThumbnailNode = {
    let node = ThumbnailNode(linkModel: model).then {
      $0.tapAction = { [weak self] in self?.thumbnailTapped() }
    }
    node.delegate = self
    return node
  }()
  private lazy var separatorNode: ASDisplayNode = createSeparator()
  var hasThumbnail: Bool {
    return model.thumbnail != nil && forceThumbnailHidden == false
  }
  private var forceThumbnailHidden = false

  override func setupBindings() {
    super.setupBindings()

    Settings.thumbnailsHidden
      .skip(1)
      .subscribe(onNext: { [weak self] _ in
        self?.setNeedsLayout()
      }).disposed(by: disposeBag)
  }

  private func thumbnailTapped() {

    if let url = link.url, model.linkType == .image {
      let mediaController = OverviewMediaViewController(url: url, linkModel: model)
      self.closestViewController?.present(mediaController)

    } else if
      let table = tableNode,
      let indexPath = indexPath,
      [LinkType.video, .selfText, .unknown].contains(model.linkType) {

      table.delegate?.tableNode?(table, didSelectRowAt: indexPath)

    } else if let url = link.url {
      LinkHandler.handleUrl(url)
    }

  }

  private func removeThumbnail() {
    forceThumbnailHidden = true
    setNeedsLayout()
    resetContextGesture()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let titleDomainSpec = ASStackLayoutSpec.vertical()
    titleDomainSpec.children = [titleTextNode, domainTextNode]
    titleDomainSpec.style.flexShrink = 1
    titleDomainSpec.style.flexGrow = 1
    titleDomainSpec.spacing = 4

    let contentHorizontal = ASStackLayoutSpec.horizontal()
    contentHorizontal.spacing = 16
    contentHorizontal.verticalAlignment = .top

    var thumbnailIndex: Int? = nil
    if Settings.thumbnailSide.value == .left {
      contentHorizontal.children = [titleDomainSpec, voteButtonSpec]
      thumbnailIndex = 0

    } else {
      contentHorizontal.children = [voteButtonSpec, titleDomainSpec]
      thumbnailIndex = 2
    }

    if Settings.thumbnailsHidden.value {
      thumbnailIndex = nil
    }

    if let index = thumbnailIndex, hasThumbnail {
      contentHorizontal.children?.insert(thumbnailNode, at: index)
    }

    let contentBottomDetailSpec = ASStackLayoutSpec.vertical()
    contentBottomDetailSpec.children = [contentHorizontal, bottomDetailSpec]
    contentBottomDetailSpec.spacing = 12
    contentBottomDetailSpec.style.flexShrink = 1
    if let flairSpec = nsfwFlairSpec {
      contentBottomDetailSpec.children?.insert(flairSpec, at: 1)
    }

    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = contentBottomDetailSpec
    insetSpec.insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    insetSpec.style.flexShrink = 1

    let separator = separatorNode
    separator.alpha = 0.7

    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.children = [insetSpec, separator]

    return verticalSpec
  }

}

extension ThumbnailListingsCellNode: ASNetworkImageNodeDelegate {

  func imageNode(_ imageNode: ASNetworkImageNode, didFailWithError error: Error) {
    log.error("thumbnail cell failed to download image", error: error)
    removeThumbnail()
  }

}
