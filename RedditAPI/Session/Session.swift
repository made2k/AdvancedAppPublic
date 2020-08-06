//
//  Session.swift
//  RedditAPI
//
//  Created by made2k on 6/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

public final class Session {

  public static let shared = Session()

  public var token: Token? {
    get {
      controller.accessToken
    }
    set {
      controller.accessToken = newValue
    }
  }

  public internal(set) var rateLimitDurationToReset: Double = 0
  public internal(set) var rateLimitUsedCount: Double = 0
  public internal(set) var rateLimitRemainingCount: Double = 0

  public weak var tokenDelegate: TokenRefreshDelegate?

  internal var controller: NetworkController

  internal init() {
    controller = NetworkController()
    controller.delegate = self
  }

}
