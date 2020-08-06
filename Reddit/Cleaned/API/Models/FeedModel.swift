//
//  FeedModel.swift
//  Reddit
//
//  Created by made2k on 5/14/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift

class FeedModel: ViewModel, ListingDisplay  {
  
  // MARK: - Static Helpers
  
  static func loadUserFeed(feedName: String) -> Promise<FeedModel> {
    
    let account = AccountModel.currentAccount.value
    
    guard account.isSignedIn else {
      return .error(APIError.notSignedIn)
    }
    
    return firstly {
      account.getSubscribedFeeds()
      
    }.firstValue {
      $0.feed.displayName ~== feedName
    }
    
  }
  
  // MARK: - Rx Elements
  
  private let feedTitleRelay = BehaviorRelay<String>(value: "")
  private(set) lazy var feedTitleObserver = feedTitleRelay.asObservable()
  var title: String { return feedTitleRelay.value }
  
  private let subredditNamesRelay = BehaviorRelay<[String]>(value: [])
  private(set) lazy var subredditNamesObserver = subredditNamesRelay.asObservable()
  var subredditNames: [String] { return subredditNamesRelay.value }
  
  private let descriptionHtmlRelay = BehaviorRelay<String?>(value: nil)
  private(set) lazy var descriptionHtmlObserver = descriptionHtmlRelay.asObservable()
  var descriptionHtml: String? { return descriptionHtmlRelay.value }

  private let descriptionRelay = BehaviorRelay<String?>(value: nil)
  private(set) lazy var descriptionObserver = descriptionRelay.asObservable()
  var feedDescription: String? { return descriptionRelay.value }
  
  // MARK: - ListingDisplay Protocol
  
  var queryable: String { return "multi-\(title.lowercasedTrim)" }
  
  var requestPath: String { return feed.path + sortType.value.rawValue }
  var subreddit: Subreddit? { return nil }
  var over18: Bool { return feed.over18 }
  
  var showHiddenPosts: Bool { return false }
  var previewType: PreviewType { return PreviewType.previewType(for: queryable) }
  
  weak var listingsDisplayDelegate: ListingDisplayDelegate?

  // MARK: - Properties
  
  let feed: Feed
  private let disposeBag = DisposeBag()

  // MARK: - Initialization
  
  init(feed: Feed) {
    self.feed = feed
    super.init()
    copyValues(from: feed)
  }
  
  // MARK: - Actions
  
  func addSubreddit(_ subredditName: String) -> Promise<Void> {
    
    return firstly {
      api.session.addSubreddit(feed: feed, subredditName: subredditName)
      
    }.done {
      self.subredditNamesRelay.append(subredditName)
    }
    
  }
  
  func removeSubreddit(_ subredditName: String) -> Promise<Void> {
    
    return firstly {
      api.session.removeSubreddit(feed: feed, subredditName: subredditName)
      
    }.map {
      return self.subredditNames.firstIndex(of: subredditName)
    
    }.done {
      guard let index = $0 else { return }
      self.subredditNamesRelay.remove(at: index)
    }
    
  }
  
  func updateFeed(name: String, description: String?, subreddits: [String]) -> Promise<Void> {
    return firstly {
      api.session.performFeedUpdate(feedPath: feed.path,
                                    displayName: name,
                                    description: description,
                                    subreddits: nil)
      
    }.done {
      self.copyValues(from: $0)
    }
  }
  
  func delete() -> Promise<Void> {
    
    return firstly {
      api.session.deleteFeed(feed: feed)
      
    }.done {
      AccountModel.currentAccount.value.multiRemoved(self)
    }
    
  }

  // MARK: - Copying
  
  private func copyValues(from feed: Feed) {
    feedTitleRelay.accept(feed.displayName)
    subredditNamesRelay.accept(feed.subreddits)
    descriptionHtmlRelay.accept(feed.descriptionHtml)
  }

}
