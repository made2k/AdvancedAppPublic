//
//  UserDefaults+Additions.swift
//  Reddit
//
//  Created by made2k on 6/13/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

extension UserDefaults {

  func openInBrowsers(forKey key: String) -> BrowserPreference? {
    guard let string = string(forKey: key) else { return nil }
    return BrowserPreference(rawValue: string)
  }

  func set(_ value: BrowserPreference, forKey key: String) {
    let rawValue = value.rawValue
    set(rawValue, forKey: key)
  }

  func openInYouTube(forKey key: String) -> YouTubePreference? {
    guard let string = string(forKey: key) else { return nil }
    return YouTubePreference(rawValue: string)
  }

  func set(_ value: YouTubePreference, forKey key: String) {
    let rawValue = value.rawValue
    set(rawValue, forKey: key)
  }

  // MARK: - Integers

  func nonZeroInteger(forKey key: String, default: Int) -> Int {
    let value = integer(forKey: key)
    if value == 0 { return `default` }
    return value
  }

}

