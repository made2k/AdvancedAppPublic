//
//  SubredditModel.swift
//  Reddit
//
//  Created by made2k on 4/3/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation
import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift

class SubredditModel: ViewModel, ListingDisplay {

  // MARK: - Static Helpers

  static func verifySubredditExists(path: String) -> Promise<SubredditModel> {
    
    if let userSubreddit = UserSubreddit.fromPath(path) {
      let model = SubredditModel(userSubreddit: userSubreddit)
      return .value(model)
    }
    
    if let cached = SubredditCache.shared.lookupModel(path) {
      return .value(cached)
    }
    
    return firstly {
      APIContainer.shared.session.getSubredditInfo(subredditName: path)
      
    }.map {
      SubredditModel(subreddit: $0)
      
    }.get {
      SubredditCache.shared.add(from: $0)
    }

  }
  
  // MARK: - Reactive
  
  private let subscribedRelay = BehaviorRelay<Bool>(value: false)
  private(set) lazy var subscribedObserver = subscribedRelay.asObservable()
  var subscribed: Bool { return subscribedRelay.value }
  
  var activeUserCount = BehaviorRelay<Int?>(value: nil)
  
  // MARK: - ListingDisplay Protocol
  
  var title: String { return (subreddit?.displayName ?? userSubreddit?.displayName).unsafelyUnwrapped }
  var queryable: String { return title.lowercasedTrim }
  
  var requestPath: String { return subredditPath + "/\(sortType.value.rawValue)" }
  var over18: Bool { return subreddit?.over18 ?? false }
  
  var showHiddenPosts: Bool = false
  var previewType: PreviewType { return PreviewType.previewType(for: queryable) }
  
  weak var listingsDisplayDelegate: ListingDisplayDelegate?
  
  // MARK: - Properties
  
  let subreddit: Subreddit?
  let userSubreddit: UserSubreddit?
  
  var subredditPath: String {
    if let subreddit = subreddit {
      return subreddit.displayNamePrefix
    }

    if let usersub = userSubreddit {
      if usersub == .front { return "" }
      return "/r/\(usersub.path)"
    }

    return ""
  }

  var isUserSubreddit: Bool { return subreddit == nil && userSubreddit != nil }
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Initialization
  
  init(subreddit: Subreddit) {
    self.subreddit = subreddit
    self.userSubreddit = nil
    
    super.init()
    commonInit()
  }
  
  init(userSubreddit: UserSubreddit) {
    self.userSubreddit = userSubreddit
    self.subreddit = nil
    
    super.init()
    commonInit()
  }
  
  private func commonInit() {
    
    if let subreddit = subreddit {
      copyValues(from: subreddit)
    }
  }
    
  // MARK: - Actions
  
  func subscribe() -> Promise<Void> {
    
    guard let subreddit = subreddit else { return .init(error: GenericError.error) }
    
    return firstly {
      api.session.setSubscribed(true, subreddit: subreddit)
      
    }.done {
      self.subscribedRelay.accept(true)
      AccountModel.currentAccount.value.userSubscribed(self)
    }
    
  }
  
  func unsubscribe() -> Promise<Void> {
    
    guard let subreddit = subreddit else { return .init(error: GenericError.error) }
    
    return firstly {
      api.session.setSubscribed(false, subreddit: subreddit)
      
    }.done {
      self.subscribedRelay.accept(false)
      AccountModel.currentAccount.value.userUnsubscribed(self)
    }
    
  }
  
  func refreshInfo() -> Promise<Subreddit> {
    
    guard let subreddit = subreddit else { return Promise(error: GenericError.error) }
    
    return firstly {
      api.session.getSubredditInfo(subreddit)
      
    }.get {
      self.copyValues(from: $0)
      
    }.get { _ in
      SubredditCache.shared.add(from: self)
    }
    
  }
  
  // MARK: - Copying
  
  private func copyValues(from subreddit: Subreddit) {
    subscribedRelay.accept(subreddit.userIsSubscriber)
    activeUserCount.accept(subreddit.activeUserCount)
  }
  
}
