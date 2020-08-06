//
//  Session+Authentication.swift
//  RedditAPI
//
//  Created by made2k on 6/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Logging
import PromiseKit

extension Session {

  private enum AssociatedKeys {
    static var refreshTokenPromise: UInt8 = 0
  }

  private var appId: String {
    return "TODO: FILL IN YOUR OWN APP ID"
  }

  private var authenticationHeader: [String: String] {
    let credentialData = "\(appId):".data(using: .utf8).unsafelyUnwrapped
    let base64Credentials = credentialData.base64EncodedString()
    return ["Authorization": "Basic \(base64Credentials)"]
  }

  private var refreshTokenPromise: Promise<Token>? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.refreshTokenPromise) as? Promise<Token>
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.refreshTokenPromise, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  func refreshToken(_ token: Token, on queue: DispatchQueue) throws -> Promise<Token> {

    if let existingPromise = refreshTokenPromise, existingPromise.isPending {
      return existingPromise
    }

    guard let refreshToken = token.refreshToken else {
      return .init(error: AuthenticationError.invalidToken)
    }

    log.info("refreshing access token")

    let parameters: [String: Encodable] = [
      "grant_type": "refresh_token",
      "refresh_token": refreshToken
    ]

    var request = try Endpoint.accessToken(postData: parameters).unauthenticatedRequest()

    request.setValue(authenticationHeader["Authorization"], forHTTPHeaderField: "Authorization")

    let promise: Promise<Token> = firstly { () -> Guarantee<Void> in
      // Use this to allow specific queue to run the data task
      Guarantee<Void>()

    }.then(on: queue) {
      URLSession.shared.dataTask(.promise, with: request)

    }.map(on: queue) {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase

      let newToken = try decoder.decode(Token.self, from: $0.data)
      return Token(accessToken: newToken.accessToken, expirationDate: newToken.expirationDate, token: token)

    }.get {
      log.info("access token was updated")
      self.tokenDelegate?.tokenWasUpdated($0)
    }

    refreshTokenPromise = promise
    return promise
  }

  public func requestAccessToken(accessCode: String) throws -> Promise<Token> {

    // Need to add a uri scheme. This was removed for public release
    let parameters: [String: Encodable] = [
      "grant_type": "authorization_code",
      "code": accessCode,
      "redirect_uri": "TODOADDTHIS://response"
    ]

    var request = try Endpoint.accessToken(postData: parameters).unauthenticatedRequest()
    request.setValue(authenticationHeader["Authorization"], forHTTPHeaderField: "Authorization")

    return firstly {
      URLSession.shared.dataTask(.promise, with: request)

    }.map {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return try decoder.decode(Token.self, from: $0.data)

    }.then {
      self.requestTokenUsingTemporarySession(token: $0)

    }.get {
      self.tokenDelegate?.tokenWasUpdated($0)
    }

  }

  /**
   When first getting an access token, we do not have the user name associated
   with the token. This uses a temporary session to fetch the account info for the
   token and then associates the name to the newly created token.
   */
  private func requestTokenUsingTemporarySession(token: Token) -> Promise<Token> {

    let temporarySession = Session()
    temporarySession.token = token

    return firstly {
      temporarySession.getAccountInfo(using: token)

    }.map {
      return $0.userName

    }.map {
      return Token(name: $0, token: token)
    }

  }

}
