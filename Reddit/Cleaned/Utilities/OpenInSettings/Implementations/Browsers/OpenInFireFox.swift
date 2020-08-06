//
//  OpenInFireFox.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation

struct OpenInFireFox: BrowserOpenable {

  static func openUrl(url: URL) {

    let escapedString = url.absoluteString.addPercentEncoding
    let firefoxUrl = URL(string: "firefox://open-url?url=\(escapedString)")

    open(firefoxUrl, fallbackUrl: url)
  }

}
