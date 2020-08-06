//
//  SubredditListCoordinator.swift
//  Reddit
//
//  Created by made2k on 5/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

typealias LoadableSelection = (ListingDisplay) -> Void

class SubredditListCoordinator: NSObject, Coordinator {

  weak var navigation: UINavigationController?
  private weak var controller: SubredditViewController?
  private let tableStyle: UITableView.Style

  let model: SubredditListViewModel
  private(set) var customAction: LoadableSelection?

  init(navigation: UINavigationController, tableStyle: UITableView.Style, customAction: LoadableSelection? = nil) {
    self.navigation = navigation
    self.tableStyle = tableStyle
    self.customAction = customAction

    model = SubredditListViewModel(account: AccountModel.currentAccount.value)
  }

  func start() {

    // Create our subreddit list controller
    let subredditController = SubredditViewController(model: model, style: tableStyle, delegate: self)
    self.controller = subredditController

    // Add our search controller
    let searchModel = SubredditSearchViewModel()
    let searchResultsController = SubredditSearchViewController(model: searchModel, delegate: self)
    let searchController = UISearchController(searchResultsController: searchResultsController)
    themeSearchController(searchController)
    searchController.searchResultsUpdater = searchModel

    subredditController.navigationItem.searchController = searchController

    // Display it
    navigation?.pushViewController(subredditController)
  }

  private func themeSearchController(_ controller: UISearchController) {
    controller.searchBar.tintColor = .secondaryLabel
  }

}
