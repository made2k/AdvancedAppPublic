//
//  SplitCoordinator.swift
//  Reddit
//
//  Created by made2k on 12/28/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class SplitCoordinator: NSObject, Coordinator {

  static private let currentRelay = BehaviorRelay<SplitCoordinator?>(value: nil)
  static let currentObserver = currentRelay.asObservable()
  static var current: SplitCoordinator! { return currentRelay.value }
  
  private(set) lazy var interfaceObserver: Observable<UIUserInterfaceStyle> = splitViewController.interfaceStyle

  private let window: UIWindow
  // TODO: Make this private
  lazy var splitViewController: RedditSplitViewController = {
    let controller = RedditSplitViewController()
    controller.preferredDisplayMode = .allVisible

    controller.delegate = UIApplication.shared.delegate as? AppDelegate
    controller.modalTransitionStyle = .crossDissolve
    controller.viewControllers = [crateNavigation(), crateNavigation()]

    return controller
  }()

  private func crateNavigation() -> UINavigationController {
    return NavigationController().then {
      $0.definesPresentationContext = true
    }
  }

  var masterNavigation: UINavigationController {
    return (splitViewController.viewControllers.first as? UINavigationController).unsafelyUnwrapped
  }
  var detailNavigation: UINavigationController {
    return splitViewController.viewControllers[safe: 1] as? UINavigationController ??
    masterNavigation
  }

  private var disposeBag = DisposeBag()

  init(window: UIWindow) {
    self.window = window
    super.init()
    SplitCoordinator.currentRelay.accept(self)
  }

  private func setupBindings() {

    disposeBag = DisposeBag()

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

    appDelegate.queuedSubreddit
      .filterNil()
      .subscribe(onNext: { [unowned self] in
        self.openListing($0, animated: false)

        // Dispatch this so as to not retrigger an update inside an update
        DispatchQueue.main.async {
          appDelegate.queuedSubreddit.accept(nil)
        }

    }).disposed(by: disposeBag)

    appDelegate.queuedInbox
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { _ in

        InboxCoordinator(split: SplitCoordinator.current).start()

        DispatchQueue.main.async {
          appDelegate.queuedInbox.accept(false)
        }

      }).disposed(by: disposeBag)
    
    appDelegate.queuedURL
      .filterNil()
      .subscribe(onNext: {
        LinkHandler.handleUrl($0)

        // Dispatch this so as to not retrigger an update inside an update
        DispatchQueue.main.async {
          appDelegate.queuedURL.accept(nil)
        }

    }).disposed(by: disposeBag)


  }

  func start() {

    let traitOverrideViewController = TraitOverridingViewController(nibName: nil, bundle: nil)
    traitOverrideViewController.addChildController(splitViewController, view: traitOverrideViewController.view)
    traitOverrideViewController.modalTransitionStyle = .crossDissolve
    
    window.rootViewController = traitOverrideViewController
    
    ListingsCoordinator(navigation: masterNavigation, delegate: self).start()

    // TODO: We need a more appropriate empty view controller here
    if let detail = splitViewController.viewControllers[safe: 1] as? UINavigationController {
      let coordinator = LinkCoordinator(navigation: detail)
      coordinator.start()
    }

    setupBindings()

  }
  
  func openListing(_ listing: ListingDisplay, animated: Bool = true) {
    ListingsCoordinator(navigation: masterNavigation, listingDisplay: listing, delegate: self).start(animated: animated)
  }

  func openSubreddit(subredditName: String) {
    ListingsCoordinator(navigation: masterNavigation, delegate: self, subredditName: subredditName).start()
  }
  
  func resetStartingSubreddit(_ listing: ListingDisplay) {
    let coordinator = ListingsCoordinator(navigation: masterNavigation, listingDisplay: listing, delegate: self)
    let controller = coordinator.startController()
    
    masterNavigation.viewControllers.replaceSubrange(0..<1, with: [controller])
  }

  func isShowing(_ controllerType: UIViewController.Type) -> Bool {
    return visibleViewControllers
      .contains(where: { type(of: $0) == controllerType })
  }

  var visibleViewControllers: [UIViewController] {
    return splitViewController.viewControllers
      .map { findLastController($0) }
  }

  /// Sometimes a navigaton controller has an embedded
  /// navigation, this finds the true last controller.
  private func findLastController(_ viewController: UIViewController) -> UIViewController {
    guard let navigation = viewController as? UINavigationController else { return viewController }

    if let internalNavigation = navigation.viewControllers.last as? UINavigationController {
      return findLastController(internalNavigation)
    }

    if let last = navigation.viewControllers.last {
      return last
    }

    return viewController
  }

}
