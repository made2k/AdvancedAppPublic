//
//  OpenInPreference.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation

class OpenInPreference: NSObject {

  static let shared = OpenInPreference()

  private let defaults = UserDefaults.standard

  private let openInBrowsersKey = "OpenInBrowsers"
  var browserPreference: BrowserPreference {
    get { return defaults.openInBrowsers(forKey: openInBrowsersKey) ?? .safariInApp }
    set { defaults.set(newValue, forKey: openInBrowsersKey) }
  }
  private var browser: BrowserOpenable.Type { return browserPreference.openable() }

  private let openInYouTubeKey = "OpenInYoutube"
  var youtubePreference: YouTubePreference {
    get { return defaults.openInYouTube(forKey: openInYouTubeKey) ?? .inApp }
    set { defaults.set(newValue.rawValue, forKey: openInYouTubeKey) }
  }
  private var youtube: YouTubeOpenable.Type? { return youtubePreference.openable() }

  private override init() {}

  // MARK: - Browsers

  func openBrowser(url: URL) {
    let safeUrl = url.safeScheme()
    browser.openUrl(url: safeUrl)
  }

  // MARK: - YouTube

  func openYoutube(url: URL) {
    if let youtube = youtube {
      youtube.openYoutubeLink(url: url)
      return
    }

    OpenInSafariInApp.openUrl(url: url)
  }

}
