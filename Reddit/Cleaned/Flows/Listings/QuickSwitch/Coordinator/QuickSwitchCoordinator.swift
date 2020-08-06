//
//  QuickSwitchCoordinator.swift
//  Reddit
//
//  Created by made2k on 12/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift
import Then
import UIKit

final class QuickSwitchCoordinator: NSObject, Coordinator, QuickSwitchViewControllerDelegate {

  let presenting: UIViewController
  lazy var navigation: UINavigationController = NavigationController().then {
    $0.navigationBar.prefersLargeTitles = false
    $0.modalTransitionStyle = .crossDissolve
    $0.modalPresentationStyle = .overCurrentContext
  }
  private var controller: QuickSwitchViewController?

  let subscribedSubreddits = BehaviorRelay<[SubredditModel]>(value: [])
  let searchResults = BehaviorRelay<[SubredditSearchResult]?>(value: nil)
  let query = BehaviorRelay<String?>(value: nil)
  private let resultsAllowed = BehaviorRelay<Bool>(value: true)

  /// Used to cancel the promise chain of a search request.
  /// Thought process being, we may not be able to cancel
  /// the actual request, but we can have that complete, but
  /// not complete the promise chain that would set results.
  private var searchCache: (promise: Promise<[SubredditSearchResult]>, cancel: () -> Void) = (.value([]), {})

  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  init(presenting: UIViewController) {
    self.presenting = presenting

    super.init()
    setupBindings()
  }

  // MARK: - Coordinator

  func start() {
    
    loadSubscribedSubreddits(account: AccountModel.currentAccount.value)

    let controller = QuickSwitchViewController(delegate: self)
    self.controller = controller

    navigation.viewControllers = [controller]

    presenting.present(navigation)
  }

  /// Restore the navigation bar and stack before this flow took over
  func finish() {
    navigation.view.endEditing(true)
    navigation.dismiss()
  }

  // MARK: - Bindings

  private func setupBindings() {

    // The query without white space, and if it's empty, is set to nil
    let safeQuery = query.asObservable()
      .map { $0?.withoutWhitespace }
      .map { $0?.isEmpty == true ? nil : $0 }
      .share()

    safeQuery
      .map { $0 != nil }
      .bind(to: resultsAllowed)
      .disposed(by: disposeBag)

    // Search when not nil
    safeQuery
      .distinctUntilChanged()
      .filterNil()
      .debounce(.milliseconds(350), scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
      .subscribe(onNext: { [unowned self] query in
        self.performSearch(query)
      }).disposed(by: disposeBag)

    // When nil, set the results to nil
    safeQuery
      .distinctUntilChanged()
      .filter { $0 == nil }
      .subscribe(onNext: { [unowned self] _ in
        self.searchResults.accept(nil)
      }).disposed(by: disposeBag)

    // When subscribed subreddits changes, if search results is nil reload
    subscribedSubreddits.asObservable()
      .filter { [unowned self] _ in self.searchResults.value == nil }
      .subscribe(onNext: { [unowned self] _ in
        self.controller?.reload()
      }).disposed(by: disposeBag)

    AccountModel.currentAccount
      .flatMap { (model: AccountModel) -> Observable<[FeedModel]> in
        model.feeds.asObservable()

      }.subscribe(onNext: { _ in
        self.controller?.reload()

      }).disposed(by: disposeBag)

    // When search results change, reload
    searchResults.asObservable()
      .distinctUntilChanged()
      .subscribe(onNext: { [unowned self] _ in
        self.controller?.reload()
      }).disposed(by: disposeBag)
  }

  private func loadSubscribedSubreddits(account: AccountModel) {

    firstly {
      account.getSubscribedSubreddits()

    }.done {
      self.subscribedSubreddits.accept($0)

    }.cauterize()

  }

  private func performSearch(_ query: String) {

    // If we have a search pending, we can't cancel the request
    // but we can cancel the promise chain
    if searchCache.promise.isFulfilled == false {
      searchCache.cancel()
    }

    var cancelChain = false

    let searchPromise = firstly {
      APIContainer.shared.session.searchSubreddits(query: query, includeNSFW: Settings.hideAllNSFW.value == false)
      
    }.get { _ in
      guard cancelChain == false else { throw PMKError.cancelled }
    }

    firstly {
      searchPromise

    }.map {
      return $0.sorted(by: { $0.subscriberCount > $1.subscriberCount })

    }.get {
      var results = $0
      // Here we manually add certain results that reddit won't inlcude by default
      self.manuallyUpdateSearchResults(&results, query: query)
      let safeValue = self.resultsAllowed.value ? results : nil

      self.searchResults.accept(safeValue)

    }.cauterize()

    let cancel = {
      cancelChain = true
    }

    searchCache = (searchPromise, cancel)
  }

  private func manuallyUpdateSearchResults(_ results: inout [SubredditSearchResult], query: String) {
    if "popular".hasPrefix(query.lowercasedTrim) {
      let popular = SubredditSearchResult(name: UserSubreddit.popular.displayName)
      results.insert(popular, at: 0)
    }

    if "all".hasPrefix(query.lowercasedTrim) {
      let all = SubredditSearchResult(name: UserSubreddit.all.displayName)
      results.insert(all, at: 0)
    }
  }

}
