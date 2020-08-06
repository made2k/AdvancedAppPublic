//
//  SubredditSearchViewController+ASTableDataSource.swift
//  Reddit
//
//  Created by made2k on 5/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension SubredditSearchViewController: ASTableDataSource {

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return model.searchResults.value.count
  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

    let subreddit = model.searchResults.value[indexPath.row]

    return {
      SubredditCellNode(
        subredditName: subreddit.name,
        iconUrl: subreddit.icon,
        overrideImage: nil,
        backgroundColor: .systemBackground
      )
    }
  }

}
