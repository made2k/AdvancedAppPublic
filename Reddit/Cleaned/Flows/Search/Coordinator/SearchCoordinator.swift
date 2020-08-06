//
//  SearchCoordinator.swift
//  Reddit
//
//  Created by made2k on 6/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI
import UIKit

class SearchCoordinator: NSObject, Coordinator {

  private weak var navigation: UINavigationController?
  private weak var controller: SearchViewController?

  private let model = SearchModel(limitToSubreddit: nil)

  init(navigation: UINavigationController) {
    self.navigation = navigation
  }

  func start() {
    let controller = SearchViewController(model: model, delegate: self)
    navigation?.pushViewController(controller)

    self.controller = controller
  }

}

extension SearchCoordinator: SearchViewControllerDelegate {

  func didSelectLinkModel(_ model: LinkModel) {
    SplitCoordinator.current.didOpenLink(model)
  }

  func didSelectUser(_ model: UserModel) {
    // TODO: This needs updating
    let vc = UserOverviewViewController(model: model)
    navigation?.pushViewController(vc)
  }

  func didSelectSubreddit(_ result: SubredditSearchResult) {

    Overlay.shared.showProcessingOverlay()

    firstly {
      SubredditModel.verifySubredditExists(path: result.name)

    }.done {
      Overlay.shared.hideProcessingOverlay()
      SplitCoordinator.current.openListing($0)

    }.catch { _ in
      Overlay.shared.flashErrorOverlay("Error loading subreddit: \(result.name)")
    }

  }

  func didSelectShowAllLinks() {
    // TODO: This needs updating
    let controller = ExpandedPostSearchViewController(searchModel: model.linkSearchModel)
    navigation?.pushViewController(controller)
  }

}
