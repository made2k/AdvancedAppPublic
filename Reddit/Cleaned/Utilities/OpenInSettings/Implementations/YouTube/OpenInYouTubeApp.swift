//
//  OpenInYouTubeApp.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation
import UIKit

struct OpenInYouTubeApp: YouTubeOpenable {

  static let scheme: String = "youtube"

  static func openYoutubeLink(url: URL) {

    let app = UIApplication.shared

    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    components?.scheme = OpenInYouTubeApp.scheme

    guard let youtubeUrl = components?.url, app.canOpenURL(url) else {
      return OpenInSafariInApp.openUrl(url: url)
    }

    app.open(youtubeUrl, options: [:], completionHandler: nil)
  }
}
