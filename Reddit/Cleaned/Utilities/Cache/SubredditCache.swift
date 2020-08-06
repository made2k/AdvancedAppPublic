//
//  SubredditCache.swift
//  Reddit
//
//  Created by made2k on 6/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI
import RxSwift

class SubredditCache: NSObject {
  
  static let shared: SubredditCache = SubredditCache()
  
  private var cache: [String: Subreddit] = [:]

  private let disposeBag = DisposeBag()
  
  private override init() {
    super.init()
    setupBindings()
  }
  
  private func setupBindings() {
    
    AccountModel.currentAccount
      .distinctUntilChanged()
      .subscribe(onNext: { _ in
        self.reset()
      }).disposed(by: disposeBag)
  }
  
  func lookup(_ path: String) -> Subreddit? {
    return cache[path.lowercasedTrim]
  }
  
  func lookupModel(_ path: String) -> SubredditModel? {
    if UserSubreddit.isUserSubreddit(path) {
      guard let userSubreddit = UserSubreddit.fromPath(path) else { return nil }
      return SubredditModel(userSubreddit: userSubreddit)
    }
    
    guard let subreddit = lookup(path) else { return nil }
    return SubredditModel(subreddit: subreddit)
  }
  
  func add(from model: SubredditModel) {
    let path = model.subredditPath.removingPrefix("r/").lowercasedTrim
    cache[path] = model.subreddit
  }
  
  func reset() {
    cache.removeAll()
  }
  
  func loadIfNeeded(_ path: String) -> Promise<SubredditModel> {
    if let cached = lookupModel(path) {
      return .value(cached)
    }
    
    return SubredditModel.verifySubredditExists(path: path)
  }
  
}
