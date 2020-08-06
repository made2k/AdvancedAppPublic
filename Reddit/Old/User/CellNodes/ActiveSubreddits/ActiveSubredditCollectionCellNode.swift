//
//  ActiveSubredditCollectionCellNode.swift
//  Reddit
//
//  Created by made2k on 1/27/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI

class ActiveSubredditCollectionCellNode: HorizontalScrollCellNode {
  let subreddits: [KarmaListSubreddit]

  init(subreddits: [KarmaListSubreddit]) {
    self.subreddits = subreddits
    
    super.init(size: 90, title: "Active Communities")
  }
  
  override func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return subreddits.count
  }
  
  override func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return { 
      ActiveSubredditsCellNode(subreddit: self.subreddits[indexPath.row])
    }
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    let subreddit = subreddits[indexPath.row]
    if let url = URL(string: "https://www.reddit.com/r/\(subreddit.displayName)") {
      LinkHandler.handleUrl(url)
    }
  }
  
}
