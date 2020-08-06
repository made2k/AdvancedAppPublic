//
//  AccountModel.swift
//  Reddit
//
//  Created by made2k on 5/21/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RxCocoa
import PromiseKit
import RedditAPI

class AccountModel: ViewModel {
  
  // MARK: - Static Helpers
  
  static func loadAccount(token: Token) -> Promise<AccountModel> {
    
    return firstly {
      APIContainer.shared.session.getAccountInfo(using: token)
      
    }.map {
      AccountModel(account: $0)
    }
    
  }
  
  static let currentAccount = BehaviorRelay<AccountModel>(value: AccountModel(account: nil))
  
  // MARK: - Properties
  
  let account: Account?
  var isGold: Bool { return account?.isGold == true }
  var isSignedIn: Bool { return account != nil }
  var username: String? { return account?.userName }

  private var userModel: UserModel?
  
  let inboxModel = InboxModel()

  let subreddits = BehaviorRelay<[SubredditModel]>(value: [])
  let feeds = BehaviorRelay<[FeedModel]>(value: [])

  var hasFetchedSubscribedSubreddits: Bool {
    return subscribedFetchCache?.isFulfilled == true
  }
  private var subscribedFetchCache: Promise<[SubredditModel]>?

  // MARK: - Initialization
  
  init(account: Account?) {
    self.account = account
  }
  
  // MARK: - Subscription Updates
  
  func userSubscribed(_ model: SubredditModel) {
    // We already have this in our data source
    guard subreddits.value.contains(where: { $0.queryable == model.queryable }) == false else { return }
    
    // Insert at the correct location
    let index = subreddits.value.firstIndex(where: { $0.title.caseInsensitiveCompare(model.title) == .orderedDescending }) ?? subreddits.value.count
    var mutableValue = subreddits.value
    mutableValue.insert(model, at: index)
    subreddits.accept(mutableValue)
  }
  
  func userUnsubscribed(_ model: SubredditModel) {
    guard let index = subreddits.value.firstIndex(where: { $0.queryable == model.queryable }) else { return }
    subreddits.remove(at: index)
  }

  // MARK: - Feed Updates
  
  func multiAdded(_ model: FeedModel) {
    feeds.append(model)
  }
  
  func multiRemoved(_ model: FeedModel) {
    guard let index = feeds.value.firstIndex(where: { model === $0 }) else { return }
    feeds.remove(at: index)
  }
  
  // MARK: - Subscription Fetching
  
  // MARK: Subreddits
  
  func getSubscribedSubreddits(force: Bool = false) -> Promise<[SubredditModel]> {

    if let cache = subscribedFetchCache, cache.isPending {
      return cache
    }
    
    // We don't need to update since we've already got values
    if subreddits.isNotEmpty && force == false {
      return .value(subreddits.value)
    }
    
    let fetchPromise: Promise<[Subreddit]>
    
    if let token = api.session.token, isSignedIn {
      fetchPromise = fetchSubscribedSubreddits(token: token)
      
    } else {
      fetchPromise = fetchDefaultSubreddits()
    }
    
    let promise = firstly {
      fetchPromise
      
    }.map {
      return $0.sorted { $0.displayName.caseInsensitiveCompare($1.displayName) == .orderedAscending }

    }.mapValues {
      SubredditModel(subreddit: $0)
      
    }.get {
      self.subreddits.accept($0)
      
    }.get(on: .global()) { subredditList in
      subredditList.forEach { SubredditCache.shared.add(from: $0) }
    }

    subscribedFetchCache = promise
    return promise
  }
  
  private func fetchSubscribedSubreddits(
    token: Token,
    loaded: [Subreddit] = [],
    paginator: Paginator = .none()) -> Promise<[Subreddit]> {

    return firstly {
      api.session.getSubscribedSubreddits(using: token, paginator: paginator)
      
    }.then { response -> Promise<[Subreddit]> in
      let collection = loaded + response.0
      let paginator = response.1
      
      if response.1.hasMore {
        return self.fetchSubscribedSubreddits(token: token,
                                              loaded: collection,
                                              paginator: paginator)
        
      } else {
        return .value(collection)
      }
    }
    
  }

  private func fetchDefaultSubreddits(loaded: [Subreddit] = [], paginator: Paginator = .none()) -> Promise<[Subreddit]> {
    
    return firstly {
      api.session.getDefaultSubreddits(paginator: paginator)
      
    }.then { response -> Promise<[Subreddit]> in
      let collection = loaded + response.0
      let paginator = response.1
      
      if response.1.hasMore {
        return self.fetchDefaultSubreddits(loaded: collection,
                                           paginator: paginator)
      
      } else {
        return .value(collection)
      }

    }
    
  }
  
  // MARK: Multireddits
  
  func getSubscribedFeeds(force: Bool = false) -> Promise<[FeedModel]> {
    
    guard let token = api.session.token, isSignedIn else {
      return .error(APIError.notSignedIn)
    }
    
    if feeds.isNotEmpty && force == false {
      return .value(feeds.value)
    }
    
    return firstly {
      api.session.getSubscribedFeeds(using: token, paginator: .none())
      
    }.mapValues {
      FeedModel(feed: $0)
      
    }.get {
      self.feeds.accept($0)
    }

  }

  // MARK: - User

  func getUserModel() -> Promise<UserModel> {

    if let model = userModel {
      return .value(model)
    }

    guard let username = username else { return .error(APIError.notSignedIn) }

    return firstly {
      api.session.getUserProfile(username: username)

    }.map {
      UserModel(user: $0)

    }.get {
      self.userModel = $0
    }

  }
  
}
