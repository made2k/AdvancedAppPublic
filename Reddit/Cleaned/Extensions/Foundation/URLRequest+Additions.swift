//
//  URLRequest+Additions.swift
//  Reddit
//
//  Created by made2k on 7/2/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

extension URLRequest {
  
  mutating func setUserAgentForReddit() {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    self.setValue("ios:com.advancedapp.Reddit:v\(version) (by /u/made2k)", forHTTPHeaderField: "User-Agent")
  }
  
}
