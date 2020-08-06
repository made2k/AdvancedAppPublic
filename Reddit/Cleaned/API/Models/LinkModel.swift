//
//  LinkModel.swift
//  Reddit
//
//  Created by made2k on 3/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation
import Logging
import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift

class LinkModel: ViewModel, VoteModelType, HideModelType, ReadModelType {

  // MARK: - Link Elements

  lazy private(set) var title = Observable.just(link.title)
  lazy private(set) var flair = Observable.just(link.flair)
  lazy private(set) var gildings = Observable.just(link.gildings)
  lazy private(set) var domain = Observable.just(link.domain)
  
  var thumbnail: URL? { return extractThumbnail() }

  // MARK: ReadModelType
  private let visited = BehaviorRelay<Bool>(value: false)
  private(set) lazy var readObserver = visited.asObservable()
  var read: Bool { return visited.value }

  internal let voteDirectionRelay = BehaviorRelay<VoteDirection>(value: .none)
  lazy private(set) var voteDirectionObserver = voteDirectionRelay.asObservable()
  var voteDirection: VoteDirection { return voteDirectionRelay.value }
  let scoreRelay = BehaviorRelay<Int>(value: 0)
  let minimumScoreTruncation = 1000
  var votable: VoteType { return link }
  var archived: Bool { return link.archived }

  let hidden = BehaviorRelay<Bool>(value: false)
  let saved = BehaviorRelay<Bool>(value: false)

  private let likePercentRelay = BehaviorRelay<Double?>(value: nil)
  lazy private(set) var likePercent = likePercentRelay.asObservable()

  private(set) lazy var linkType = LinkType.guessType(for: link)
  let selfText: BehaviorRelay<String?>

  let commentSort = BehaviorRelay<CommentSort>(value: Settings.defaultCommentSort)

  // MARK: - Properties

  let link: Link
  var name: String { return link.name }
  private(set) var commentTree: CommentTreeModel?

  var isUsersPost: Bool { return AccountModel.currentAccount.value.username == link.author }

  // MARK: - Initialization

  init(_ link: Link, commentTree: CommentTreeModel?) {
    self.link = link
    self.commentTree = commentTree
    self.selfText = BehaviorRelay<String?>(value: link.selftextHtml)

    super.init()

    copyValues(from: link)
  }
  
  private func extractThumbnail() -> URL? {

    if Settings.showNSFWPreviews {
    
      if
        let thumbnail = link.thumbnail,
        thumbnail.absoluteString != "self" && thumbnail.absoluteString != "default" {
        return thumbnail
        
      } else if let preview = link.preview {
        return extractThumbnailFromPreview(preview, includeNSFW: true, includeSpoilers: Settings.showSpoilers)
        
      } else {
        return nil
      }
    }
    
    // We're not showing NSFW thumbnails, try getting thumb from preview first
    if
      let preview = link.preview,
      let url = extractThumbnailFromPreview(preview, includeNSFW: false, includeSpoilers: Settings.showSpoilers) {
      return url
    }

    // If the link is NSFW, we've already validated we don't show previews, return nil
    if link.over18 || (Settings.showSpoilers == false && link.spoiler) { return nil }

    guard link.thumbnail?.scheme != nil && link.thumbnail?.host != nil else { return nil }

    // There's no other options, just return thumbnail if it exists
    return link.thumbnail
  }
  
  private func extractThumbnailFromPreview(_ preview: Preview, includeNSFW: Bool, includeSpoilers: Bool) -> URL? {
    
    let targetSize: CGFloat = 50
    
    // If we have an obfuscated photo, show the blurred image if we're not including
    // nsfw and the image is nsfw, or if the link is a spoiler, and we're not including spoilers
    if let obfuscated = preview.obfuscatedFitting(targetSize) {
      if (includeNSFW == false && link.over18) || (link.spoiler && includeSpoilers == false) {
        return obfuscated.url
      }
    }
    
    // We didn't have an obfuscated photo, make sure we're not violating spoilers or nsfw
    if (includeNSFW || link.over18 == false) && link.spoiler == false {
      return preview.previewFitting(targetSize)?.url
    }
    
    // In the case we would violate, just don't show the thumbnail
    return nil
  }

  // MARK: - Actions

  @discardableResult
  func markRead() -> Promise<Void> {
    guard visited.value == false else { return .value(()) }

    // Mark read locally
    MarkRead.shared.markVisited(link: link)
    visited.accept(true)

    // Mark read remote
    let account = AccountModel.currentAccount.value
    guard account.isSignedIn && account.isGold else { return .value(()) }

    firstly {
      api.session.markVisited(link: link)

    }.catch {
      log.error($0)
    }

    return .value(())
  }

  func setLocallyMarkReadOnly() {
    MarkRead.shared.markVisited(link: link)
    visited.accept(true)
  }

  @discardableResult
  func markUnread() -> Promise<Void> { return .error(GenericError.error) }

  func refreshCommentTree() -> Promise<CommentTreeModel> {

    return firstly {
      api.session.loadComments(link: link, sort: commentSort.value, limit: Settings.numberOfCommentsToLoad)

    }.get {
      self.copyValues(from: $0.0)

    }.map {
      return $0.1
      
    }.map {
      return CommentTreeModel(tree: $0)
      
    }.get {
      self.commentTree = $0  
    }

  }

  func resetCommentTree() {
    commentTree = nil
  }

  func setVoteDirection(_ voteDirection: VoteDirection) -> Promise<Void> {

    let existingValue = self.voteDirection

    voteDirectionRelay.accept(voteDirection)

    return firstly {
      api.session.setVote(thing: link, direction: voteDirection)

    }.recover { error -> Promise<Void> in
      log.error("error setting vote value", error: error)
      self.voteDirectionRelay.accept(existingValue)
      throw error
    }

  }

  func setSaved(_ saved: Bool) -> Promise<Void> {

    let existingValue = self.saved.value

    return firstly {
      api.session.setSaved(saved, thing: link)
      
    }.done {
      self.saved.accept(saved)
      
    }.recover { error -> Promise<Void> in
      log.error("error setting saved value", error: error)
      self.saved.accept(existingValue)
      throw error
    }

  }

  func delete() -> Promise<Void> {
    guard isUsersPost else { return .error(OldAPIError.invalidRequest) }
    return api.session.delete(thing: link)
  }

  // MARK: - Copying

  private func copyValues(from link: Link) {
    visited.accept(link.visited || visited.value)
    voteDirectionRelay.accept(link.direction)
    scoreRelay.accept(link.score)
    hidden.accept(link.hidden)
    saved.accept(link.saved)
    likePercentRelay.accept(link.upvoteRatio)
  }

}

extension LinkModel {

  static func == (lhs: LinkModel, rhs: LinkModel) -> Bool {

    return lhs.link.name == rhs.link.name &&
    lhs.voteDirection.rawValue == rhs.voteDirection.rawValue

  }

}
