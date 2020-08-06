//
//  MigrateIos13Theme.swift
//  Reddit
//
//  Created by made2k on 8/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AppVersionMonitor
import Logging
import PromiseKit

class MigrateIos13Theme: NSObject, MigrationAction {

  func migrate() -> Guarantee<Void> {
    return when(migrateFont())
  }

  /**
   System font family changes in iOS 13, since we previously saved the font family name when using system font, we'll correct that here
   to clear the font value if needed.
   */
  private func migrateFont() -> Guarantee<Void> {

    let fontKey = "com.reddit.settings.fontfamily"
    let iOS12DefaultFontFamily = ".SF UI Text"
    let savedFontFamily = UserDefaults.standard.string(forKey: fontKey)

    guard savedFontFamily == iOS12DefaultFontFamily else { return .value(()) }
    log.info("Updating saved font to new system default type")
    UserDefaults.standard.removeObject(forKey: "com.reddit.settings.fontfamily")

    // Reset font settings in case it's already been initialized
    FontSettings.shared.fontFamily.accept(UIFont.systemFont(ofSize: 10).familyName)

    return .value(())
  }

}

