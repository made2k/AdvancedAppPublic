//
//  SubredditListViewModel.swift
//  Reddit
//
//  Created by made2k on 5/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RxCocoa
import RxSwift

class SubredditListViewModel: NSObject {

  let favoriteNames: BehaviorRelay<[String]>
  let defaultSubreddits: [(SubredditModel, UIImage)]
  let customFeeds: BehaviorRelay<[FeedModel]>
  let subscribedSubreddits: BehaviorRelay<[SubredditModel]>

  let loadingSubscribed = BehaviorRelay<Bool>(value: false)
  let loadingFeeds = BehaviorRelay<Bool>(value: false)

  let needsReload = BehaviorRelay<Void>(value: ())

  var canEditSubscribed: Bool { return user.isSignedIn }

  private let user: AccountModel

  init(account: AccountModel) {

    self.user = account

    favoriteNames = Settings.favoriteSubreddits

    defaultSubreddits = [
      (DefaultSubreddits.front(), R.image.subreddit_frontPage().unsafelyUnwrapped),
      (DefaultSubreddits.popular(), R.image.subreddit_popular().unsafelyUnwrapped),
      (DefaultSubreddits.all(), R.image.subreddit_all().unsafelyUnwrapped),
      (DefaultSubreddits.random(), R.image.subreddit_random().unsafelyUnwrapped)
    ]

    customFeeds = account.feeds
    subscribedSubreddits = account.subreddits

    super.init()

   loadDataIfNeeded()
  }

  private func loadDataIfNeeded() {

    if subscribedSubreddits.isEmpty {
      refreshSubscribedSubreddits().cauterize()
    }

    if user.isSignedIn && customFeeds.value.isEmpty {
      refreshFeeds().cauterize()
    }

  }

  func refreshAll() -> Promise<Void> {
    return when(fulfilled: refreshSubscribedSubreddits(), refreshFeeds())
  }

  func refreshSubscribedSubreddits() -> Promise<Void> {

    loadingSubscribed.accept(true)

    return firstly {
      user.getSubscribedSubreddits(force: true)

    }.get { _ in
      self.loadingSubscribed.accept(false)

    }.done {
      self.subscribedSubreddits.accept($0)
    }

  }

  func refreshFeeds() -> Promise<Void> {

    loadingFeeds.accept(true)

    return firstly {
      user.getSubscribedFeeds(force: true)

    }.get { _ in
      self.loadingFeeds.accept(false)

    }.done {
      self.customFeeds.accept($0)
    }

  }
  
  func addFeed(_ feed: FeedModel) {
    customFeeds.append(feed)
  }

  func deleteFeed(_ feed: FeedModel) -> Promise<Void> {
    return firstly {
      feed.delete()

    }.done {
      guard self.user.isSignedIn else { return }
      guard let index = self.customFeeds.value.firstIndex(where: { $0 === feed }) else { return }
      self.customFeeds.remove(at: index)
    }
  }

  func unsubscribe(_ model: SubredditModel) -> Promise<Void> {

    return firstly {
      model.unsubscribe()

    }.done {
      self.user.userUnsubscribed(model)
    }

  }

}
