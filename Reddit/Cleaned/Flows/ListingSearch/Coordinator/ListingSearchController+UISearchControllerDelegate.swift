//
//  ListingSearchController+UISearchControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 12/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

extension ListingSearchCoordinator: UISearchControllerDelegate {

  func didDismissSearchController(_ searchController: UISearchController) {
    model.query.accept(nil)
  }

}
