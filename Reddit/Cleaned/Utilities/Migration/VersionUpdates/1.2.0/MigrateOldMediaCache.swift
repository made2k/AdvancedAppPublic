//
//  Migrate120.swift
//  Reddit
//
//  Created by made2k on 2/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import Logging
import PromiseKit

/**
 Removes the old data store for video downloads.
 
 Previous to v1.2.0 a different cache was used for video
 downloads. A dictionary holding file names and dates
 was persistently saved in a dictionary in user defaults.
 
 This migration simply removes that dictionary if it exists
 for the key in the correct format.
 */
class MigrateOldMediaCache: NSObject, MigrationAction {
  
  func migrate() -> Guarantee<Void> {
    
    log.info("migration removing old media cache")
    
    let mediaCacheKey = "com.advancedapp.reddit.mediacache"
    
    if UserDefaults.standard.dictionary(forKey: mediaCacheKey) as? [String: Date] != nil {
      log.debug("migration found a dictionary cache")
      UserDefaults.standard.removeObject(forKey: mediaCacheKey)
    }
    
    return .value(())
  }
  
  
}
