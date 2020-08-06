//
//  OpenInBrave.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation

struct OpenInBrave: BrowserOpenable {

  static func openUrl(url: URL) {

    let escapedString = url.absoluteString.addPercentEncoding
    let braveUrl = URL(string: "brave://open-url?url=\(escapedString)")

    open(braveUrl, fallbackUrl: url)
  }

}
