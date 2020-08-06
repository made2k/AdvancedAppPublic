//
//  LiveCommentModel.swift
//  Reddit
//
//  Created by made2k on 9/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI
import RxCocoa

protocol LiveCommentModelDelegate: class {

  func didFetchComments(comments: [CommentModel])
  func commentAddedAt(index: Int)

}

final class LiveCommentModel: ViewModel {

  // MARK: - Rx Sources

  // TODO: Setup RxDatasources on this
  private let commentsRelay = BehaviorRelay<[CommentModel]>(value: [])
  private(set) lazy var commentsObserver = commentsRelay.asObservable()
  var comments: [CommentModel] { return commentsRelay.value }

  // MARK: - Computed Properties

  /// Current attempts at fetching comments without new results
  private var emptyAttemptCount = 0
  private var timeInterval: TimeInterval {

    let targetRefresh = Settings.liveCommentInterval
    let maxAllowedDuration: TimeInterval = min(targetRefresh * 3, 45)

    // We quickly fall off to not over request
    var adjustedRefreshTime = targetRefresh + (3.0 * Double(emptyAttemptCount))

    let rateLimitRemaining = api.session.rateLimitRemainingCount
    let rateLimiteResetDuration = api.session.rateLimitDurationToReset

    // Add an additional 10 seconds since our rate limit is running up.
    if rateLimitRemaining < 50 && rateLimiteResetDuration > 0 {
      adjustedRefreshTime += 10
    }

    return min(adjustedRefreshTime, maxAllowedDuration)
  }

  // MARK: - Properties

  let link: Link
  private var isActive = false
  private var updateTimer: Timer?
  weak var delegate: LiveCommentModelDelegate?

  init(link: Link) {
    self.link = link

    super.init()
  }

  deinit {
    updateTimer?.invalidate()
  }

  // MARK: - Loading

  func startLoading() {
    isActive = true
    fetchNewComments()
  }

  func stopLoading() {
    isActive = false
    updateTimer?.invalidate()
    updateTimer = nil
  }

  private func fetchNewComments() {
    guard isActive else { return }

    firstly {
      api.session.loadComments(link: link, sort: .new, limit: 20)

    }.map {
      return $0.1

    }.compactMapValues {
      switch $0 {
      case .comment(let value):
        return value

      case .more:
        return nil
      }

    }.filterValues {
      // Top level and not stickied
      return $0.parentName == self.link.name && $0.stickied == false

    }.mapValues { (comment: Comment) -> CommentModel in
      return CommentModel(comment, parent: nil)

    }.done { (models: [CommentModel]) -> Void in
      self.finalizeValues(newValues: models)

    }.catch { (error: Error) in
      log.error("unable to fetch comments", error: error)
    }

  }

  private func finalizeValues(newValues: [CommentModel]) {

    // We'll always schedule an update after we return
    defer { scheduleUpdate() }

    guard newValues.isNotEmpty else {
      emptyAttemptCount += 1
      return
    }

    emptyAttemptCount = 0

    var mutableValue = commentsRelay.value

    var newComments: [CommentModel] = []
    for comment in newValues {
      if let existing = mutableValue.first(where: { $0.id == comment.id }) {
        existing.copyValues(from: comment.comment)

      } else {
        newComments.append(comment)
      }
    }

    mutableValue.insert(contentsOf: newComments, at: 0)
    commentsRelay.accept(mutableValue)
    delegate?.didFetchComments(comments: newComments)
  }

  private func scheduleUpdate() {
    guard isActive else { return }

    updateTimer = Timer.scheduledTimer(withTimeInterval: timeInterval,
                                       repeats: false) { [unowned self] _ in
      self.fetchNewComments()
    }

  }

  // MARK: - Add Comments


  func addComment(_ text: String, parent: Thing) -> Promise<Void> {

    let parentComment: CommentModel?

    if parent.kind == .comment {
      parentComment = commentsRelay.value.first(where: { $0.comment.id == parent.id })

    } else {
      parentComment = nil
    }

    return firstly {
      api.session.submitComment(parent: parent, body: text)

    }.map {
      return CommentModel($0, parent: parentComment)

    }.done {
      self.addChildComment(comment: $0, parentComment: parentComment)
    }

  }

  private func addChildComment(comment: CommentModel, parentComment: CommentModel?) {

    if let parent = parentComment, let index = commentsRelay.value.firstIndex(where: { $0 === parent }) {
      var mutableValue = commentsRelay.value
      mutableValue.insert(comment, at: index)
      commentsRelay.accept(mutableValue)
      delegate?.commentAddedAt(index: index)

    } else {
      var mutableValue = commentsRelay.value
      mutableValue.insert(comment, at: 0)
      commentsRelay.accept(mutableValue)
      delegate?.commentAddedAt(index: 0)

    }

  }

}
