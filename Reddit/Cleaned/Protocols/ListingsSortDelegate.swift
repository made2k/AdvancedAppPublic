//
//  ListingsSortDelegate.swift
//  Reddit
//
//  Created by made2k on 6/30/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI
import UIKit

protocol ListingsSortDelegate {

  func changedSortType(type: LinkSortType, timing: TimePeriod)

}

extension ListingsSortDelegate where Self: UIViewController {

  func showSortSelection() {

    let alert = AlertController()

    let types = [LinkSortType.hot, .new, .rising, .controversial, .top]

    types
      .map { sortAction($0) }
      .forEach { alert.addAction($0) }

    alert.show()
  }

  private func sortAction(_ type: LinkSortType) -> AlertAction {

    switch type {
    case .top, .controversial:
      return AlertAction(title: type.displayName, icon: type.icon, hasNext: true) { [weak self] in
        self?.showTimingSelection(for: type)
      }

    default:
      break
    }

    return AlertAction(title: type.displayName, icon: type.icon) { [weak self] in
      self?.changedSortType(type: type, timing: .all)
    }

  }

  private func showTimingSelection(for sortType: LinkSortType) {
    let alert = AlertController()

    let types = [TimePeriod.hour, .day, .week, .month, .year, .all]

    types
      .map { timingAction(type: sortType, timing: $0) }
      .forEach { alert.addAction($0) }

    alert.show()
  }

  private func timingAction(type: LinkSortType, timing: TimePeriod) -> AlertAction {
    return AlertAction(title: timing.displayName, icon: timing.icon) { [weak self] in
      self?.changedSortType(type: type, timing: timing)
    }
  }

}
