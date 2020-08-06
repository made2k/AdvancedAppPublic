//
//  UIApplication+Extension.swift
//  Reddit
//
//  Created by made2k on 6/21/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit

extension UIApplication {

  var marketingVersion: String? {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  }

  var gitHash: String? {
    Bundle.main.infoDictionary?["GIT_COMMIT_HASH"] as? String
  }
  
  var currentAppIcon: UIImage? {
    
    guard
      let alternateName = alternateIconName,
      supportsAlternateIcons else { return UIImage.appIcon }
    
    return UIImage(named: alternateName) ?? UIImage.appIcon    
  }

  func activeWindow() -> UIWindow? {

    connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .compactMap { $0 as? UIWindowScene }
      .first?.windows
      .filter(\.isKeyWindow)
      .first
  }

  static func openApplicationSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
  
}
