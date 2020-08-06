//
//  QuickSwitchCoordinator+UISearchBarDelegate.swift
//  Reddit
//
//  Created by made2k on 12/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import PromiseKit
import RxSwift
import UIKit

extension QuickSwitchCoordinator: UISearchBarDelegate {
    
  // MARK: - UISearchBarDelegate
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    Settings.quickSwitchKeyboardMode.accept(true)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    if Settings.quickSwitchKeyboardMode.value {
      finish()
    }
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    finish()
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let query = searchBar.text?.withoutWhitespace, query.isNotEmpty {
      openSubreddit(queryString: query)

    } else {
      finish()
    }
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    query.accept(searchText)
  }
  
}
