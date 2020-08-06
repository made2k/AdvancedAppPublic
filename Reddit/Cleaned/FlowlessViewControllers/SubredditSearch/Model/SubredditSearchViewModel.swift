//
//  SubredditSearchViewModel.swift
//  Reddit
//
//  Created by made2k on 5/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift
import UIKit

class SubredditSearchViewModel: NSObject {

  let query = BehaviorRelay<String?>(value: nil)
  let searchResults = BehaviorRelay<[SubredditSearchResult]>(value: [])

  private let disposeBag = DisposeBag()

  override init() {
    super.init()
    setupBindings()
  }

  private func setupBindings() {

    query
      .distinctUntilChanged()
      .debounce(.milliseconds(450), scheduler: SerialDispatchQueueScheduler(qos: .default))
      .flatMapLatest { [unowned self] in self.searchObservable($0) }
      .bind(to: searchResults)
      .disposed(by: disposeBag)

  }

  private func searchObservable(_ query: String?) -> Observable<[SubredditSearchResult]> {

    return Observable.create { [unowned self] observer in

      firstly {
        self.performSearch(query)

      }.done {
        observer.onNext($0)

      }.done {
        observer.onCompleted()

      }.catch {
        observer.onError($0)
      }

      return Disposables.create()
    }

  }

  private func performSearch(_ query: String?) -> Promise<[SubredditSearchResult]> {
    guard
      let query = query?.removingCharacters(in: CharacterSet.subredditQuery.inverted),
      query.isNotEmpty else {
        return .value([])
    }
    
    return APIContainer.shared.session.searchSubreddits(query: query, includeNSFW: Settings.hideAllNSFW.value == false)
  }

}

extension SubredditSearchViewModel: UISearchResultsUpdating {

  func updateSearchResults(for searchController: UISearchController) {
    query.accept(searchController.searchBar.text)
  }

}
