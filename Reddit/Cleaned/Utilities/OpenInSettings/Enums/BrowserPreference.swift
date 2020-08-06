//
//  BrowserPreference.swift
//  Reddit
//
//  Created by made2k on 6/13/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import UIKit

enum BrowserPreference: String, CaseIterable {
  case safariInApp = "Safari In App"
  case safariInAppReader = "Safari In App Reader"
  case chrome = "Chrome"
  case firefox = "FireFox"
  case focus = "FireFox Focus"
  case brave = "Brave"
  case dolphin = "Dolphin"
  case opera = "Opera"

  var canOpen: Bool {

    switch self {
    case .brave: return canOpenScheme("brave://")
    case .chrome: return canOpenScheme("googlechrome://")
    case .dolphin: return canOpenScheme("dolphin://")
    case .firefox: return canOpenScheme("firefox://")
    case .focus: return canOpenScheme("firefox-focus://")
    case .opera: return canOpenScheme("opera-http://")
    case .safariInApp, .safariInAppReader: return true
    }

  }

  private func canOpenScheme(_ scheme: String) -> Bool {
    guard let url = URL(string: scheme) else { return false }
    return UIApplication.shared.canOpenURL(url)
  }

  func openable() -> BrowserOpenable.Type {

    switch self {
    case .safariInAppReader: return OpenInSafariInAppReader.self
    case .chrome: return OpenInChrome.self
    case .brave: return OpenInBrave.self
    case .firefox: return OpenInFireFox.self
    case .focus: return OpenInFocus.self
    case .dolphin: return OpenInDolphin.self
    case .opera: return OpenInOpera.self
    case .safariInApp: return OpenInSafariInApp.self
    }

  }
  
}
