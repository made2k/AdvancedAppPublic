//
//  SubredditSearchViewController+ASTableDelegate.swift
//  Reddit
//
//  Created by made2k on 5/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension SubredditSearchViewController: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let item = model.searchResults.value[indexPath.row]
    delegate?.didSelectSearchResult(item)
  }

}
