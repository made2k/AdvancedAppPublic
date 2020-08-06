//
//  ListingSearchCoordinator+SearchResultsUpdater.swift
//  Reddit
//
//  Created by made2k on 12/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

extension ListingSearchCoordinator: UISearchResultsUpdating {

  func updateSearchResults(for searchController: UISearchController) {
    let queryString = searchController.searchBar.text
    query.accept(queryString)
  }

}
