//
//  Session+Comment.swift
//  RedditAPI
//
//  Created by made2k on 6/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Logging
import PromiseKit

extension Session {

  public func loadComments(link: Link, sort: CommentSort, limit: Int) -> Promise<(Link, [CommentType])> {

    firstly {
      controller.request(.fetchComments(link: link, sort: sort, limit: limit))

    }.map { (response: LinkCommentResponse) -> (Link, [CommentType]) in
      return (response.link, response.comments)
    }

  }

  public func loadMoreComments(more: More, link: Link, sort: CommentSort) -> Promise<[CommentType]> {

    firstly {
      controller.request(.loadMore(childrenIds: Array(more.childrenIds.prefix(100)), sort: sort, linkName: link.name))

    }.map { (response: JsonDataResponse<ThingsResponse<DataResponse<CommentTypeParser>>>) -> [CommentType] in
      response.data.things.map(\.data.commentType).filterEmpty()

    }.map {
      self.constructUnstructuredComments($0, from: more)
    }

  }

  public func submitComment(parent: Thing, body: String) -> Promise<Comment> {
    submitComment(parentName: parent.name, body: body)
  }
  
  public func submitComment(parentName: String, body: String) -> Promise<Comment> {
    
    firstly {
      controller.request(.submitComment(parentName: parentName, body: body))
      
    }.map { (response: JsonDataResponse<ThingsResponse<DataResponse<Comment>>>) -> Comment in
      guard let value = response.data.things.first?.data else {
        throw APIError.badResponse
      }
      return value
    }
    
  }
  
  public func submitMessage(parent: Message, body: String) -> Promise<Message> {
    submitMessage(parentName: parent.name, body: body)
  }
  
  public func submitMessage(parentName: String, body: String) -> Promise<Message> {

    firstly {
      controller.request(.submitComment(parentName: parentName, body: body))

    }.map { (response: JsonDataResponse<ThingsResponse<DataResponse<Message>>>) -> Message in
      guard let value = response.data.things.first?.data else {
        throw APIError.badResponse
      }
      return value
    }

  }

}

private extension Session {
  
  /**
   When we fetch more comments, we get a flat list of comments that have empty replies
   but who's children live in that list. This function modifies the comments to have them
   structured as children of their respective parent.
   */
  private func constructUnstructuredComments(_ comments: [CommentType], from more: More) -> [CommentType] {

    let topLevelParentName = more.parentName

    var commentList: [CommentType] = comments

    for (index, comment) in commentList.enumerated().reversed() {

      let targetParentName: String

      switch comment {
      case .comment(let value):
        targetParentName = value.parentName

      case .more(let value):
        targetParentName = value.parentName
      }

      if targetParentName == topLevelParentName {
        continue
      }

      let optionalParentIndex = commentList.firstIndex { (comment: CommentType) in

        switch comment {
        case .comment(let value):
          return value.name == targetParentName

        case .more:
          return false
        }

      }

      guard let parentIndex = optionalParentIndex else {
        preconditionFailure("error parsing more children")
      }

      let commentType = commentList[parentIndex]
      let parentComment: Comment

      switch commentType {
      case .comment(let value):
        parentComment = value

      case .more:
        preconditionFailure("found more type when expected comment type")
      }

      guard parentIndex < index else {
        commentList.remove(at: index)
        log.warn("Malformed child list when getting more comments. Dropping comment.")
        continue
      }

      let updatedComment = updateChildren(for: parentComment, adding: comment)
      commentList.remove(at: index)
      commentList.remove(at: parentIndex)
      commentList.insert(.comment(value: updatedComment), at: parentIndex)
    }

    return commentList
  }

  private func updateChildren(for parent: Comment, adding child: CommentType) -> Comment {
    var updatedChildren = parent.children
    updatedChildren.insert(child, at: 0)

    let newComment = Comment(comment: parent, children: updatedChildren)
    return newComment
  }

}
