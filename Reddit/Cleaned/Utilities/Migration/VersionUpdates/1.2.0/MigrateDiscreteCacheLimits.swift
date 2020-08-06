//
//  MigrateDiscreteCacheLimits.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import Logging
import PromiseKit

/**
 Originally the was a single max cache size that was primarly
 only used for videos. Images just got ASNetworkNodes default.
 This migration splits the original cache size in half and allocates
 it evenly to images and videos.
 */
class MigrateDiscreteCacheLimits: NSObject, MigrationAction {

  func migrate() -> Guarantee<Void> {

    log.info("migration splitting max cache into two")

    let oldCache = Settings.depricatedMaxCacheSize
    let newValues = Int(oldCache / 2)

    Settings.maxImageCacheSize.accept(newValues)
    Settings.maxGifCacheSize.accept(newValues)

    log.info("caches are now set to \(newValues) bytes each")

    return .value(())
  }

}
