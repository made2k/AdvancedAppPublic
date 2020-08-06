//
//  ListingSearchCoordinator+UISearchBarDelegate.swift
//  Reddit
//
//  Created by made2k on 12/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RedditAPI
import UIKit

extension ListingSearchCoordinator: UISearchBarDelegate {

  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    searchSort.accept(searchType(for: selectedScope))
  }

  private func searchType(for index: Int) -> SearchSortType {
    switch index {
    case 0:
      return .relevance
    case 1:
      return .new
    case 2:
      return .hot
    case 3:
      return .top
    default:
      return .comments
    }
  }

}
