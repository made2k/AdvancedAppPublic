//
//  SubredditRedirectHandler.swift
//  RedditAPI
//
//  Created by made2k on 3/20/20.
//  Copyright © 2020 made2k. All rights reserved.
//

class SubredditRedirectHandler: NSObject, URLSessionTaskDelegate {

  func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    willPerformHTTPRedirection response: HTTPURLResponse,
    newRequest request: URLRequest,
    completionHandler: @escaping (URLRequest?) -> Void
  ) {

    guard let url = request.url else {
      return completionHandler(nil)
    }

    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return completionHandler(nil)
    }

    components.host = "www.reddit.com"
    components.queryItems = [
      .rawJson()
    ]
    components.path = "\(components.path)"

    if components.path.hasSuffix(".json") == false {
      components.path = "\(components.path).json"
    }

    guard let newUrl = components.url else {
      return completionHandler(nil)
    }

    let newRequest = URLRequest(url: newUrl)
    completionHandler(newRequest)

  }

}
