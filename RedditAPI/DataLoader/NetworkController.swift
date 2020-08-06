//
//  NetworkController.swift
//  RedditAPI
//
//  Created by made2k on 3/8/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Logging
import PromiseKit

internal class NetworkController {

  // MARK: - Properties

  private static let networkQueue = DispatchQueue(label: "com.reddit.network", qos: .default)

  private static let redirectHandler: URLSessionTaskDelegate = SubredditRedirectHandler()
  private static let operationQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 5
    queue.qualityOfService = .default
    return queue
  }()
  private static let urlSession = URLSession(
    configuration: .default,
    delegate: redirectHandler,
    delegateQueue: operationQueue
  )

  internal var accessToken: Token?
  private var refreshTokenPromise: Promise<URLRequest>?

  weak var delegate: NetworkControllerDelegate?

  // MARK: - Requests

  func request<T: Decodable>(_ endpoint: Endpoint) -> Promise<T> {

    let urlRequest: URLRequest

    do {
      urlRequest = try constructRequest(from: endpoint)

    } catch {
      return Promise<T>(error: error)
    }

    if let url = urlRequest.url {
      log.verbose("making request: \(url)")
    }

    return firstly { () -> Guarantee<Void> in
      Guarantee<Void>()

    }.then(on: Self.networkQueue) { () -> Promise<URLRequest> in
      self.refreshAccessTokenIfNeeded(urlRequest)

    }.then(on: Self.networkQueue) {
      Self.urlSession.dataTask(.promise, with: $0)
    }
    .get {
      self.delegate?.responseReceived($0.response)
    }
    .validate()
    .map {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return try decoder.decode(T.self, from: $0.data)

    }.recover { (error: Error) -> Promise<T> in
      log.error("error making request to: \(String(describing: urlRequest.url))")
      log.error(error)
      throw error
    }

  }

  func requestVoid(_ endpoint: Endpoint) -> Promise<Void> {

    let urlRequest: URLRequest

    do {
      urlRequest = try constructRequest(from: endpoint)

    } catch {
      return Promise<Void>(error: error)
    }

    if let url = urlRequest.url {
      log.verbose("making request: \(url)")
    }

    return firstly { () -> Guarantee<Void> in
      Guarantee<Void>()

    }.then(on: Self.networkQueue) { () -> Promise<URLRequest> in
      self.refreshAccessTokenIfNeeded(urlRequest)

    }.then(on: Self.networkQueue) {
      Self.urlSession.dataTask(.promise, with: $0)

    }.get {
      self.delegate?.responseReceived($0.response)
    }
    .validate()
    .asVoid()
    .recover { (error: Error) in
      log.error("error making request to: \(String(describing: urlRequest.url))")
      log.error(error)
      throw error
    }

  }

  private func constructRequest(from endpoint: Endpoint) throws -> URLRequest {

    var urlRequest: URLRequest

    if accessToken != nil {
      urlRequest = try endpoint.authenticatedRequest()

    } else {
      urlRequest = try endpoint.unauthenticatedRequest()
    }

    urlRequest.setOAuth2Token(accessToken)
    urlRequest.setUserAgentForReddit()

    return urlRequest
  }

  private func refreshAccessTokenIfNeeded(_ request: URLRequest) -> Promise<URLRequest> {

    guard request.url?.path != Endpoint.accessToken(postData: [:]).path else {
      return .value(request)
    }

    if let existingPromise = refreshTokenPromise, existingPromise.isPending {
      return existingPromise
    }

    guard let token = accessToken else {
      return .value(request)
    }

    guard token.isExpired else {
      return .value(request)
    }

    guard let delegate = delegate else {
      return Promise(error: APIError.internalError)
    }

    var request: URLRequest = request

    let promise: Promise<URLRequest> = firstly {
      try delegate.refreshToken(token, on: Self.networkQueue)

    }.get(on: Self.networkQueue) {
      self.accessToken = $0
      request.setOAuth2Token($0)

    }.map(on: Self.networkQueue) { _ in
      request
    }

    refreshTokenPromise = promise
    return promise
  }

}
