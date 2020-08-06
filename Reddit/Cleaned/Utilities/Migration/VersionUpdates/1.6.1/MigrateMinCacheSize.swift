//
//  MigrateMinCacheSize.swift
//  Reddit
//
//  Created by made2k on 4/10/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Foundation
import PromiseKit

class MigrateMinCacheSize: NSObject, MigrationAction {

  func migrate() -> Guarantee<Void> {

    // 100 MB
    let minSize: Int = 100 * 1000 * 1000

    if Settings.maxGifCacheSize.value < minSize {
      Settings.maxGifCacheSize.accept(minSize)
    }

    if Settings.maxImageCacheSize.value < minSize {
      Settings.maxImageCacheSize.accept(minSize)
    }

    return Guarantee<Void>()
  }

}

