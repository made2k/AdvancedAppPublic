//
//  ExpandedPostSearchViewController+ListingDisplayDelegate.swift
//  Reddit
//
//  Created by made2k on 7/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import CoreGraphics

extension ExpandedPostSearchViewController: ListingDisplayDelegate {

  func didOpenLink(_ linkModel: LinkModel) {
    SplitCoordinator.current.didOpenLink(linkModel)
  }

}
