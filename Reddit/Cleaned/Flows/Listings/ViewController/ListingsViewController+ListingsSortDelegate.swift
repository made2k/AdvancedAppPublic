//
//  ListingsViewController+ListingsSortDelegate.swift
//  Reddit
//
//  Created by made2k on 1/3/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

extension ListingsViewController: ListingsSortDelegate {

  func changedSortType(type: LinkSortType, timing: TimePeriod) {
    sortBarButtonItem.image = type.icon.barButtonSafe
    delegate?.changedSort(sort: type, timing: timing)
  }

}
