//
//  OpenInProTube.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation
import UIKit

struct OpenInProTube: YouTubeOpenable {

  static let scheme: String = "protube"

    static func openYoutubeLink(url: URL) {

      var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
      components?.scheme = OpenInProTube.scheme

      guard let protubeUrl = components?.url, app.canOpenURL(protubeUrl) else {
        return OpenInSafariInApp.openUrl(url: url)
      }

      app.open(protubeUrl, options: [:], completionHandler: nil)
    }
  
}
