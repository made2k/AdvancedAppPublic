//
//  OpenInFocus.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation

struct OpenInFocus: BrowserOpenable {

  static func openUrl(url: URL) {

    let escapedString = url.absoluteString.addPercentEncoding
    let focusUrl = URL(string: "firefox-focus://open-url?url=\(escapedString)")

    open(focusUrl, fallbackUrl: url)

  }
}
