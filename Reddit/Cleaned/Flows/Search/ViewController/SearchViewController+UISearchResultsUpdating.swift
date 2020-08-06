//
//  SearchViewController+UISearchResultsUpdating.swift
//  Reddit
//
//  Created by made2k on 6/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension SearchViewController: UISearchResultsUpdating {

  func updateSearchResults(for searchController: UISearchController) {
    let query = searchController.searchBar.text
    model.query.accept(query)
  }

}
