//
//  RedditAuthHandler.swift
//  Reddit
//
//  Created by made2k on 2/25/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI

class RedditAuthHandler: NSObject {

  static let shared = RedditAuthHandler()

  private let session = Session.shared
  
  private override init() { }
  
  /**
   Handle the auth code provided by reddit after the initial authentication.
   Reddit will call back to our app with our URL scheme and have an access code
   That will be used for requesting a token.

   - Parameter url: The callback url from reddit that should contain our access code
   - Returns: True if we handle the access code, false otherwise
   */
  func getAccessCode(url: URL) -> String? {
    // TODO: Better url scheme
    guard url.scheme == AccountsViewController.uriScheme else { return nil }
    return url.queryValue(for: "code")
  }
  
  /**
   An access token is required for authenticated calls to the reddit api.
   This token received by this call should be saved and used while it is not expired.

   - Parameter code: The access code used to fetch the access token.
   */
  func requestAccessToken(code: String) throws -> Promise<Token> {
    return try session.requestAccessToken(accessCode: code)

  }
}
