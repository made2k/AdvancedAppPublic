//
//  CommentModel.swift
//  Reddit
//
//  Created by made2k on 3/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift

class CommentModel: ViewModel, CommentModelType, VoteModelType {

  // MARK: - CommentModelType Conformance
  var id: String { return comment.id }
  var name: String { return comment.name }
  private(set) weak var parent: CommentModelType?
  var topComment: CommentModel {
    var top = self

    while let parent = top.parent as? CommentModel {
      top = parent
    }

    return top
  }

  var children: [CommentModelType] = []
  var allChildren: [CommentModelType] {

    var returnValue: [CommentModelType] = []

    // Recursivly grab all children
    func parseChildren(_ comments: [CommentModelType]) {

      for child in comments {
        returnValue.append(child)
        parseChildren(child.children)
      }

    }

    parseChildren(children)
    return returnValue
  }

  var isUserComment: Bool {
    let account = AccountModel.currentAccount.value
    guard account.isSignedIn else { return false }
    return comment.author == account.username
  }

  // MARK: - Comment Elements

  private let authorTextRelay = BehaviorRelay<String>(value: "")
  private(set) lazy var authorTextObserver = authorTextRelay.asObservable()
  var author: String { return authorTextRelay.value }

  private(set) lazy var ageText: Observable<String> = Observable.just(comment.created)
    .map { $0.timeAgo }

  private let archivedRelay = BehaviorRelay<Bool>(value: false)
  private(set) lazy var archivedObserver = archivedRelay.asObservable()
  var archived: Bool { return archivedRelay.value }

  // TODO: There should probably be an HTML object, instead of using String
  private let bodyHtmlRelay = BehaviorRelay<String>(value: "")
  private(set) lazy var bodyHtmlObserver = bodyHtmlRelay.asObservable()
  var bodyHtml: String { return bodyHtmlRelay.value }
  
  private let bodyRelay = BehaviorRelay<String>(value: "")
  private(set) lazy var bodyObserver = bodyRelay.asObservable()
  var body: String { return bodyRelay.value }

  private let distinguishedRelay = BehaviorRelay<Distinguished?>(value: nil)
  private(set) lazy var distinguishedColor = distinguishedRelay
    .map { $0?.color }

  private let savedRelay = BehaviorRelay<Bool>(value: false)
  private(set) lazy var saved = savedRelay.asObservable()

  let scoreRelay = BehaviorRelay<Int>(value: 0)
  let minimumScoreTruncation = 10_000

  let voteDirectionRelay = BehaviorRelay<VoteDirection>(value: .none)
  var votable: VoteType { return comment }

  // MARK: - UX Elements

  let collapsed = BehaviorRelay<Bool>(value: false)
  var hidden: Bool {
    guard let parentComment = parent as? CommentModel else { return false }
    return parentComment.hidden || parentComment.collapsed.value
  }
  var level: Int {
    if let parent = parent as? CommentModel {
      return parent.level + 1
    }

    return 0
  }

  // MARK: - Properties

  let comment: Comment
  private(set) var isDeleted: Bool = false

  // MARK: - Initialization

  init(_ comment: Comment, parent: CommentModel?) {
    self.comment = comment
    self.parent = parent

    super.init()

    self.children = comment.children
      .compactMap({ CommentModelTypeFactory.modelType(for: $0, parent: self) })

    copyValues(from: comment)

  }

  // MARK: - Actions
  
  func delete() -> Promise<Void> {
    guard isUserComment else { return .error(OldAPIError.invalidRequest) }
    return firstly {
      api.session.delete(thing: comment)
      
    }.done {
      self.isDeleted = true
    }
  }

  /**
   Mark this comment as deleted. This will update the author and body to
   show as [Deleted]
   */
  func markAsDeleted() {
    isDeleted = true
    bodyHtmlRelay.accept("<div class=\"md\"><p>[deleted]</p>\n</div>")
    authorTextRelay.accept("[deleted]")
  }

  func setParent(_ model: CommentModelType) {
    parent = model
  }

  // MARK: - Copying

  func copyValues(from comment: Comment) {
    authorTextRelay.accept(comment.author)
    archivedRelay.accept(comment.archived)
    bodyHtmlRelay.accept(comment.bodyHtml)
    bodyRelay.accept(comment.body)
    distinguishedRelay.accept(comment.distinguished)
    savedRelay.accept(comment.saved)
    scoreRelay.accept(comment.score)
    voteDirectionRelay.accept(comment.direction)
  }

}
