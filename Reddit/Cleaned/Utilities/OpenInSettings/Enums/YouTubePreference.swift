//
//  YouTubePreference.swift
//  Reddit
//
//  Created by made2k on 6/13/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import UIKit

enum YouTubePreference: String, CaseIterable {
  case inApp = "In App"
  case youtube = "YouTube"
  case protube = "ProTube"

  var canOpen: Bool {

    switch self {
    case .inApp: return true
    case .protube: return canOpenScheme("protube://")
    case .youtube: return canOpenScheme("youtube://")
    }

  }

  private func canOpenScheme(_ scheme: String) -> Bool {
    guard let url = URL(string: scheme) else { return false }
    return UIApplication.shared.canOpenURL(url)
  }

  func openable() -> YouTubeOpenable.Type? {

    switch self {
    case .inApp: return nil
    case .youtube: return OpenInYouTubeApp.self
    case .protube: return OpenInProTube.self
    }

  }
}
