//
//  SearchModel.swift
//  Reddit
//
//  Created by made2k on 6/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import RedditAPI
import RxCocoa
import RxSwift

class SearchModel: NSObject {

  let query = BehaviorRelay<String?>(value: nil)

  // Relays
  
  private let linkResultsRelay = BehaviorRelay<[LinkModel]>(value: [])
  private let userResultsRelay = BehaviorRelay<[UserModel]>(value: [])
  private let subredditResultsRelay = BehaviorRelay<[SubredditSearchResult]>(value: [])

  // Observers
  
  private(set) lazy var linkResultsObserver: Observable<[LinkModel]> = {
    return linkResultsRelay.asObservable().share(replay: 1)
  }()
  private(set) lazy var userResultsObserver: Observable<[UserModel]> = {
    return userResultsRelay.asObservable().share(replay: 1)
  }()
  private(set) lazy var subredditResultsObserver: Observable<[SubredditSearchResult]> = {
    return subredditResultsRelay.asObservable().share(replay: 1)
  }()
  
  // Values

  var linkResults: [LinkModel] { return linkResultsRelay.value }
  var userResults: [UserModel] { return userResultsRelay.value }
  var subredditResults: [SubredditSearchResult] { return subredditResultsRelay.value}
  
  // Models

  let linkSearchModel: LinkSearchModel
  private let userSearchModel = UserSearchModel()
  private let subredditSearch = SubredditSearchViewModel()

  private let disposeBag = DisposeBag()

  init(limitToSubreddit subreddit: Subreddit?) {
    linkSearchModel = LinkSearchModel(limitSubredditName: subreddit?.displayName, delegate: nil)

    super.init()

    setupBindings()
  }

  private func setupBindings() {

    query
      .bind(to: linkSearchModel.query)
      .disposed(by: disposeBag)

    linkSearchModel
      .searchResultsObserver
      .bind(to: linkResultsRelay)
      .disposed(by: disposeBag)

    query
      .bind(to: userSearchModel.query)
      .disposed(by: disposeBag)

    userSearchModel
      .searchResultsObserver
      .bind(to: userResultsRelay)
      .disposed(by: disposeBag)

    query
      .bind(to: subredditSearch.query)
      .disposed(by: disposeBag)

    subredditSearch.searchResults
      .bind(to: subredditResultsRelay)
      .disposed(by: disposeBag)

  }

}
