//
//  OpenInChrome.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation

struct OpenInChrome: BrowserOpenable {

  static func openUrl(url: URL) {
    
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    components?.scheme = "googlechrome"

    open(components?.url, fallbackUrl: url)
  }

}
