//
//  LiveCommentsCoordinator+ASTableDataSource.swift
//  Reddit
//
//  Created by made2k on 2/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//
import AsyncDisplayKit

extension LiveCommentsCoordinator: ASTableDataSource {

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return model.comments.count
  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

    let comment = model.comments[indexPath.row]

    return {
      LiveCommentCellNode(model: comment, link: nil)
    }

  }

}
