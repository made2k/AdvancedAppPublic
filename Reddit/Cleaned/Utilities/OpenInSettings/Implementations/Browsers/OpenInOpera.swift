//
//  OpenInOpera.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation

struct OpenInOpera: BrowserOpenable {

  static func openUrl(url: URL) {

    let newUrlString = "opera-" + url.absoluteString
    let operaUrl = URL(string: newUrlString)

    open(operaUrl, fallbackUrl: url)
  }
}
