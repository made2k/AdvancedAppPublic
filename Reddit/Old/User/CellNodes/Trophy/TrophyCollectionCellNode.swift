//
//  TrophyCollectionCellNode.swift
//  Reddit
//
//  Created by made2k on 1/27/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI

class TrophyCollectionCellNode: HorizontalScrollCellNode {
  
  let trophies: [Trophy]
  
  init(trophies: [Trophy]) {
    self.trophies = trophies
    super.init(size: 80, title: "Trophies")
  }

  
  override func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return trophies.count
  }
  
  override func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let trophy = trophies[indexPath.row]
    
    return {
      return TrophyCellNode(trophy: trophy)
    }
  }

}
