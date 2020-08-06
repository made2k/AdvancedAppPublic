//
//  CommentTreeModel.swift
//  Reddit
//
//  Created by made2k on 3/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation
import Logging
import PromiseKit
import RedditAPI
import SwiftyJSON
import Utilities

class CommentTreeModel: ViewModel {

  private(set) var allComments: [CommentModelType]
  private var moreLoadActions = Set<String>()

  init(tree: [CommentType]) {

    allComments = tree
      .compactMap({ CommentModelTypeFactory.modelType(for: $0, parent: nil) })
      .sorted(by: { $0.isUserComment && $1.isUserComment == false })
      .flatMap { [$0] + $0.allChildren }

    super.init()
    
    filterComments()
  }
  
  func filterComments() {
        
    DispatchQueue.main.sync {
      allComments.forEach {
        guard let model = $0 as? CommentModel else { return }
        model.collapsed.accept(FilterPreference.shared.isFiltered(thing: model.comment))
      }
    }
    
  }
  
  func isAlreadyLoading(more: MoreModel) -> Bool {
    return moreLoadActions.contains(more.id)
  }

  func addComment(commentModel: CommentModel) {
    // Make sure we don't already have this model.
    guard allComments.contains(where: { $0.id == commentModel.id }) == false else {
      log.warn("attempt to add a comment already in the comment tree")
      return
    }
    // Find the index of the parent we're adding the comment to
    let parentName = commentModel.parent?.name ?? commentModel.comment.parentName
    let parentIndex = allComments.firstIndex(where: { $0.name == parentName }) ?? -1

    if let parent = allComments[safe: parentIndex] {
      commentModel.setParent(parent)
      (parent as? CommentModel)?.children.insert(commentModel, at: 0)
    }

    let allNewComments = [commentModel] + commentModel.allChildren

    allComments.insert(contentsOf: allNewComments, at: parentIndex + 1)
  }

  func commentDeleted(model: CommentModel) {

    // If the comment has children, it won't be deleted. Instead
    // it'll me marked as deleted which updates it's content to show
    // it's been deleted.
    if model.children.isEmpty {
      guard let index = allComments.firstIndex(where: { $0.id == model.id }) else {
        log.warn("Could not find comment to be removed in the tree")
        return
      }
      allComments.remove(at: index)
      
      if
        let parent = model.parent as? CommentModel,
        let index = parent.children.firstIndex(where: { $0.id == model.id }) {
        parent.children.remove(at: index)
      }

    } else {
      model.markAsDeleted()
    }

  }

  /**
   Load remaining comments and return a promise on completion
   with the number of comments retreived including the replaced
   More.
   */
  func loadMoreComments(more: MoreModel, link: Link, sort: CommentSort) -> Promise<Int> {

    guard let replaceIndex = allComments.firstIndex(where: { $0.id == more.id }) else {
      return .init(error: GenericError.error)
    }
    
    moreLoadActions.insert(more.id)

    return firstly {
      api.session.loadMoreComments(more: more.object, link: link, sort: sort)

    }.compactMapValues {
      CommentModelTypeFactory.modelType(for: $0, parent: more.parent as? CommentModel)
      
    }.get {
      guard let comment = more.parent as? CommentModel else { return }
      guard let index = comment.children.firstIndex(where: { $0 === more }) else { return }
      comment.children.remove(at: index)
      comment.children.insert(contentsOf: $0, at: index)
      
    }.flatMapValues {
      [$0] + $0.allChildren

    }.get {
      self.allComments.remove(at: replaceIndex)
      self.allComments.insert(contentsOf: $0, at: replaceIndex)
      
    }.map {
      return $0.count
      
    }.ensure {
      self.moreLoadActions.remove(more.id)
    }

  }

}
