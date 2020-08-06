//
//  Session+NetworkControllerDelegate.swift
//  RedditAPI
//
//  Created by made2k on 4/1/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Logging
import PromiseKit

extension Session: NetworkControllerDelegate {

  func responseReceived(_ response: URLResponse) {
    updateRateLimit(with: response)
  }

  private func updateRateLimit(with response: URLResponse?) {

    guard let httpResponse = response as? HTTPURLResponse else {
      return
    }

    if let reset = httpResponse.allHeaderFields["x-ratelimit-reset"] as? String {
      rateLimitDurationToReset = Double(reset) ?? 0
    }

    if let used = httpResponse.allHeaderFields["x-ratelimit-used"] as? String {
      rateLimitUsedCount = Double(used) ?? 0
    }

    if let remaining = httpResponse.allHeaderFields["x-ratelimit-remaining"] as? String {
      rateLimitRemainingCount = Double(remaining) ?? 0
    }

    if rateLimitRemainingCount < 200 && rateLimitDurationToReset > 0 {
      log.verbose("x_ratelimit_reset \(rateLimitDurationToReset)")
      log.verbose("x_ratelimit_used \(rateLimitUsedCount)")
      log.verbose("x_ratelimit_remaining \(rateLimitRemainingCount)")
    }
  }

}
