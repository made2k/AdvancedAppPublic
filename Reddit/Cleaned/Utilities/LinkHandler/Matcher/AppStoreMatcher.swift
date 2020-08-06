//
//  AppStoreMatcher.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import UIKit

struct AppStoreMatcher {
  
  private static let oldHost = "itunes.apple.com"
  private static let newHost = "apps.apple.com"
  
  static func match(_ url: URL) -> URL? {
    
    guard url.host == oldHost || url.host == newHost else { return nil }
    
    return UIApplication.shared.canOpenURL(url) ? url : nil
  }
  
}
