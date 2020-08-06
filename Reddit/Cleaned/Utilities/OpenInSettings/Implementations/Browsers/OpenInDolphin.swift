//
//  OpenInDolphin.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation

struct OpenInDolphin: BrowserOpenable {

  static func openUrl(url: URL) {

    let urlString = "dolphin://" + url.absoluteString
    let dolphinUrl = URL(string: urlString)

    open(dolphinUrl, fallbackUrl: url)

  }

}
