//
//  AlbumImageCellNode.swift
//  Reddit
//
//  Created by made2k on 2/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

class AlbumImageCellNode: ASCellNode {
  
  private let albumImage: AlbumImage
  private let mediaNode: UniversalMediaNode
  
  init(albumImage: AlbumImage) {
    self.albumImage = albumImage
    self.mediaNode = UniversalMediaNode(mediaUrl: albumImage.url)
    self.mediaNode.setMediaSize(albumImage.resolution, overrideMaxSize: true)
    
    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASWrapperLayoutSpec(layoutElement: mediaNode)
  }

}
