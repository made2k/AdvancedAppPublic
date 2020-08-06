//
//  ListingSearchCoordinator.swift
//  Reddit
//
//  Created by made2k on 12/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI
import RxCocoa
import RxOptional
import RxSwift
import UIKit

final class ListingSearchCoordinator: NSObject, Coordinator {

  private weak var navigationItem: UINavigationItem?

  let model: LinkSearchModel
  private weak var delegate: ListingsCoordinatorDelegate?

  private let controller = ASTableController(style: .plain).then {
    $0.hideEmptyCells()
    $0.node.backgroundColor = .systemBackground
    $0.node.keyboardDismissMode = .onDrag
  }

  let query = BehaviorRelay<String?>(value: nil)
  let searchSort = BehaviorRelay<SearchSortType>(value: .relevance)

  private let disposeBag = DisposeBag()
  private var searchPromise: Promise<Void> = .value(())

  init(model: LinkSearchModel,
       navigationItem: UINavigationItem,
       delegate: ListingsCoordinatorDelegate) {

    self.model = model
    self.navigationItem = navigationItem
    self.delegate = delegate

    super.init()
    
    controller.node.batchFetchingDelegate = self
    model.bind(to: controller.node, delegate: SharedListingsCellDelegate.shared)

    setupBindings()
  }

  func start() {
    navigationItem?.searchController = createSearchController()
  }

  func cleanup() {
    DispatchQueue.main.async {
      // The navigation controller keeping a reference to this will retain
      self.controller.navigationController?.viewControllers = []
    }
  }

  // This was a property, but keeping a reference was problematic for retain cycles
  private func createSearchController() -> UISearchController {
    let searchController = UISearchController(searchResultsController: controller)

    searchController.delegate = self
    searchController.searchResultsUpdater = self
    searchController.searchBar.delegate = self

    searchController.searchBar.tintColor = .secondaryLabel

    searchController.searchBar.scopeButtonTitles = ["relevance", "new", "hot", "top", "comments"]

    if let subreddit = model.limitToSubreddit {
      searchController.searchBar.placeholder = "Search r/\(subreddit)"
    } else {
      searchController.searchBar.placeholder = "Search all of reddit"
    }

    return searchController
  }

  private func setupBindings() {

    query
      .bind(to: model.query)
      .disposed(by: disposeBag)

    model
      .searchResultsObserver
      .map { $0.isEmpty }
      .distinctUntilChanged()
      .asVoid()
      .subscribe(onNext: { [unowned self] in
        self.controller.node.reloadData()
      }).disposed(by: disposeBag)

    searchSort
      .subscribe(onNext: { [unowned self] in
        self.model.setSearchType(type: $0, timing: .all)
      }).disposed(by: disposeBag)

    searchSort.asObservable()
      .subscribeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] sortType in

        self.model.setSearchType(type: sortType, timing: .all)
        self.controller.node.reloadData()
        self.model.query.accept(self.query.value)

    }).disposed(by: disposeBag)

  }

  private func reset() {
    model.reset()
    controller.node.reloadData()
  }

}
