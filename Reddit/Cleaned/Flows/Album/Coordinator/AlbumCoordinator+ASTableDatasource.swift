//
//  AlbumCoordinator+ASTableDatasource.swift
//  Reddit
//
//  Created by made2k on 2/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension AlbumCoordinator: ASTableDataSource {
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return albumImages.count
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    let image = albumImages[section]
    return image.imageDescription.isNilOrEmpty ? 1 : 2
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let image = albumImages[indexPath.section]
    
    if indexPath.row == 0 {
      return {
        AlbumImageCellNode(albumImage: image)
      }
      
    } else {
      let description = image.imageDescription.unsafelyUnwrapped
      return {
        AlbumDescriptionCellNode(description: description)
      }
    }
  }
  
}
