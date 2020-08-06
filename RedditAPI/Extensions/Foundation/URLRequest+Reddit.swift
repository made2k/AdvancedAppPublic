//
//  URLRequest+Reddit.swift
//  RedditAPI
//
//  Created by made2k on 6/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

extension URLRequest {

  mutating func setOAuth2Token(_ token: Token?) {
    if let token = token {
      setValue("bearer " + token.accessToken, forHTTPHeaderField: "Authorization")
    }
  }

  mutating func setUserAgentForReddit() {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    self.setValue("ios:com.advancedapp.Reddit:v\(version) (by /u/made2k)", forHTTPHeaderField: "User-Agent")
  }

}
