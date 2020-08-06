//
//  ListingsCoordinator+Previewing.swift
//  Reddit
//
//  Created by made2k on 12/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation

extension ListingsCoordinator {

  func togglePreviewTypeForSubreddit() {

    // Without a loader, we can't save the persisting object to the DB
    guard let listing = listingDisplay else { return }

    let currentPreviewType = PreviewType.previewType(for: listing.queryable)

    // Reversal here
    let newValue: PreviewType = currentPreviewType == .preview ? .thumbnail : .preview

    if let existing = realm
      .objects(SubredditPreviewType.self)
      .filter("subreddit = '\(listing.queryable)'")
      .first {

      try? realm.write {
        existing.previewType = newValue.rawValue
      }

    } else {

      try? realm.write {
        let preview = SubredditPreviewType(listing.queryable, previewType: newValue)
        realm.add(preview)
      }
    }

    controller?.reloadData(maintainScrollPosition: true)
  }

}
