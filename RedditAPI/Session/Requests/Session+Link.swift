//
//  Session+Link.swift
//  RedditAPI
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import PromiseKit

extension Session {

  public func loadLink(
    subredditName: String?,
    linkName: String,
    postTitle: String?,
    focusId: String?,
    context: String?
  ) -> Promise<(Link, [CommentType])> {

    let endpoint: Endpoint

    if
      let subredditName = subredditName,
      let postTitle = postTitle {

      endpoint = .fullLink(
        subredditName: subredditName,
        linkName: linkName,
        postTitle: postTitle,
        focusId: focusId,
        context: context
      )

    } else {
      endpoint = .shortLink(linkName: linkName)
    }

    return firstly {
      controller.request(endpoint)

    }.map { (response: LinkCommentResponse) -> (Link, [CommentType]) in
      (response.link, response.comments)
    }

  }

  public func markVisited(link: Link) -> Promise<Void> {
    return markVisited(links: [link])
  }
  
  public func markVisited(links: [Link]) -> Promise<Void> {
    guard links.isEmpty == false else { return .value(()) }
    return controller.requestVoid(.markVisited(links))
  }

  public func setHidden(hidden: Bool, name: String) -> Promise<Void> {
    setHidden(hidden: hidden, names: [name])
  }

  public func setHidden(hidden: Bool, names: [String]) -> Promise<Void> {
    controller.requestVoid(.setHidden(hidden, names: names))
  }

  public func submitLink(
    subredditName: String,
    title: String,
    url: URL,
    sendReplies: Bool
  ) -> Promise<URL?> {

    firstly {
      
      controller
        .request(
          .submitLink(
            subredditName: subredditName,
            title: title,
            url: url,
            sendReplies: sendReplies
          )
        )

    }.map { (response: JsonDataResponse<LinkSubmission>) -> URL? in
      response.data.url
    }

  }

  public func submitText(
    subredditName: String,
    title: String,
    text: String,
    sendReplies: Bool
  ) -> Promise<URL?> {

    firstly {

      controller
        .request(
          .submitSelfpost(
            subredditName: subredditName,
            title: title,
            text: text,
            sendReplies: sendReplies
          )
        )

    }.map { (response: JsonDataResponse<LinkSubmission>) -> URL? in
      response.data.url
    }

  }

}
