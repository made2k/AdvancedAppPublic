//
//  ListingsCoordinator.swift
//  Reddit
//
//  Created by made2k on 12/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import PromiseKit
import RealmSwift
import RedditAPI
import RxSwift
import UIKit

class ListingsCoordinator: NSObject, Coordinator {

  let navigation: UINavigationController
  private(set) weak var delegate: ListingsCoordinatorDelegate?

  private(set) var listingDisplay: ListingDisplay? {
    didSet { listingsWasSet(listingDisplay) }
  }

  /*
   Keeping a weak refrence to controller while
   the controller keeps a strong reference to us.

   This allows the coordinator to stay active
   while the controller is in the heirarchy.
   */
  weak var controller: ListingsViewController? {
    didSet {
      guard let listing = listingDisplay else { return }
      startSearchModel(limitSubredditName: listing.subreddit?.displayName)
    }
  }

  var searchCoordinator: ListingSearchCoordinator?
  var quickSwitchCoordinator: QuickSwitchCoordinator?

  let realm = try! Realm()
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  init(navigation: UINavigationController?,
       listingDisplay: ListingDisplay,
       delegate: ListingsCoordinatorDelegate) {

    self.navigation = navigation ?? NavigationController()
    self.listingDisplay = listingDisplay
    self.delegate = delegate

    super.init()
    commonInit()
    registerUserActivity(with: listingDisplay)
    listingsWasSet(listingDisplay)
  }

  /// Initialize with a soft laodable object.
  /// This will fetch the subreddit info if needed before fetching posts.
  init(navigation: UINavigationController?,
       delegate: ListingsCoordinatorDelegate,
       subredditName: String) {

    self.navigation = navigation ?? NavigationController()
    self.delegate = delegate
    
    super.init()

    firstly {
      SubredditModel.verifySubredditExists(path: subredditName)
      
    }.done {
      self.listingDisplay = $0
      self.registerUserActivity(with: $0)
    }

    commonInit()
  }

  /// Initialize without any loadable object. This will fetch the
  /// default loader before loading the posts
  init(navigation: UINavigationController, delegate: ListingsCoordinatorDelegate) {
    self.navigation = navigation
    self.delegate = delegate

    super.init()
    commonInit()

    firstly {
      getDefaultLoader()

    }.done {
      self.listingDisplay = $0
    }

  }

  private func commonInit() {
    setupBindings()

    if let display = listingDisplay {
      controller?.listingDisplayWasSet(display)
    }
  }

  deinit {
    searchCoordinator?.cleanup()
  }

  // MARK: - Coordinator

  func start() {
    start(animated: true)
  }

  func start(animated: Bool) {
    // Create our controller
    let controller = startController()

    let animated = navigation.viewControllers.isEmpty == false && animated
    navigation.pushViewController(controller, animated: animated)
  }

  func startController() -> ListingsViewController {
    let controller = ListingsViewController(delegate: self).then {
      $0.definesPresentationContext = true
      $0.title = listingDisplay?.title
    }
    self.controller = controller

    if let listingDisplay = listingDisplay {
      listingDisplay.bind(to: controller.tableNode)
    }

    // setup the post loader
    // register the activity if needed
    if let display = listingDisplay {
      controller.listingDisplayWasSet(display)
      registerUserActivity(with: display)
    }

    return controller
  }

  private func startSearchModel(limitSubredditName: String?) {
    guard let delegate = delegate else { return }
    guard let controller = controller else { return }

    let searchModel = LinkSearchModel(limitSubredditName: limitSubredditName, delegate: self)
    searchCoordinator = ListingSearchCoordinator(model: searchModel,
                                                 navigationItem: controller.navigationItem,
                                                 delegate: delegate)
    searchCoordinator?.start()
  }

  // MARK: - Bindings

  private func setupBindings() {

    Settings.showPreview.asDriver()
      .skip(1)
      .distinctUntilChanged()
      .drive(onNext: { [unowned self] _ in
        self.controller?.reloadData(maintainScrollPosition: true)
      }).disposed(by: disposeBag)

  }

  // MARK: - Helpers

  private func listingsWasSet(_ listings: ListingDisplay?) {
    guard let listings = listings else { return }

    controller?.title = listings.title
    listings.listingsDisplayDelegate = self

    if let tableNode = controller?.tableNode {
      listings.bind(to: tableNode)
    }
    
    startSearchModel(limitSubredditName: listings.subreddit?.displayName)
    controller?.listingDisplayWasSet(listings)
  }

}

extension ListingsCoordinator: ListingDisplayDelegate {

  func didOpenLink(_ linkModel: LinkModel) {
    delegate?.didOpenLink(linkModel)
  }
  
}
