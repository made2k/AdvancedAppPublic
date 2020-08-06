//
//  OpenInBrowser.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation
import UIKit

protocol BrowserOpenable {

  static func openUrl(url: URL)

}

extension BrowserOpenable {

  static var app: UIApplication {
    return UIApplication.shared
  }

  static func resortDefault(url: URL) {
    OpenInSafariInApp.openUrl(url: url)
  }

  static func open(_ url: URL?, fallbackUrl: URL? = nil) {

    guard let url = url, app.canOpenURL(url) else {

      if let fallbackUrl = fallbackUrl {
        resortDefault(url: fallbackUrl)
      }

      return
    }


    app.open(url, options: [:]) { result in

      if let fallbackUrl = fallbackUrl, result == false {
        resortDefault(url: fallbackUrl)
      }

    }

  }
  
}
