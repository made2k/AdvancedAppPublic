//
//  ArticleCellNode.swift
//  Reddit
//
//  Created by made2k on 10/28/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit

/**
 Displays an article
 */
class LinkContentArticleCellNode: ASCellNode {
  
  private let model: LinkModel
  private let controlNode: ASControlNode
  private let contextMenu: ContextMenu?
  
  init(linkModel: LinkModel) {
    self.model = linkModel
    self.controlNode = ArticleControlNode(linkModel: linkModel)

    if let url = linkModel.link.url {
      self.contextMenu = UrlPreviewContextMenu(url: url, mediaSize: nil)

    } else {
      self.contextMenu = nil
    }
    
    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    backgroundColor = .systemBackground
  }

  override func didLoad() {
    super.didLoad()
    contextMenu?.register(view: view)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    return ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16),
      child: controlNode)
    
  }
}

/**
 A "button" that lives within the cell, that handles opening the article.
 */
private class ArticleControlNode: ASControlNode {
  
  private static let thumbnailSize: CGFloat = 65
  
  private let model: LinkModel
  
  private let thumbnailNode = ASNetworkImageNode().then {
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
    $0.cornerRoundingType = .precomposited
    $0.cornerRadius = 10
    let size = ArticleControlNode.thumbnailSize
    $0.style.preferredSize = CGSize(width: size, height: size)
  }
  private let urlTextNode = TextNode(color: .secondaryLabel).then {
    $0.style.flexShrink = 1
    $0.maximumNumberOfLines = 3
  }
  
  private var previewUrl: URL? { return model.thumbnail }
  private var hideThumbnail = false
  
  init(linkModel: LinkModel) {
    self.model = linkModel
    
    super.init()
    
    automaticallyManagesSubnodes = true
    
    tapAction = {
      guard let url = linkModel.link.url else { return }
      LinkHandler.handleUrl(url)
    }
    
    thumbnailNode.url = previewUrl
    thumbnailNode.delegate = self
    
    urlTextNode.text = linkModel.link.url?.absoluteString ?? "Link: \(linkModel.title)"
    
    // Bold the host part of the url string
    if let host = linkModel.link.url?.host, let currentAttributed = urlTextNode.attributedText {
      
      let attributed = NSMutableAttributedString(attributedString: currentAttributed)
      attributed.setSubstringFont(host, font: urlTextNode.font.bold)
      urlTextNode.attributedText = attributed
    }
    
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [urlTextNode]
    if previewUrl != nil && hideThumbnail == false {
      horizontal.children?.insert(thumbnailNode, at: 0)
    }
    horizontal.spacing = 12
    horizontal.verticalAlignment = .center
    horizontal.style.flexShrink = 1
    
    return horizontal
  }
  
}

extension ArticleControlNode: ASNetworkImageNodeDelegate {

  func imageNode(_ imageNode: ASNetworkImageNode, didFailWithError error: Error) {
    hideThumbnail = true
    setNeedsLayout()
  }

}
