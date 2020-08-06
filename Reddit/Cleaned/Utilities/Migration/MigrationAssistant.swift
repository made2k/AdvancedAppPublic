//
//  MigrationAssistant.swift
//  Reddit
//
//  Created by made2k on 2/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AppVersionMonitor
import Foundation
import PromiseKit
import RealmSwift

class MigrationAssistant: NSObject {
  
  static var shared = MigrationAssistant()
  
  private let monitor = AppVersionMonitor.sharedMonitor
  private var actionList: [MigrationAction] = []
  
  private var hasMigrated = false
  
  private override init() {
    monitor.startup()
  }
  
  func migrateIfNeeded() -> Guarantee<Void> {
    
    guard hasMigrated == false else { return Guarantee<Void>() }
    hasMigrated = true

    // Realm may optionally be migrated at any time
    addMigration(MigrateRealm())
    // iOS 13 isn't an app migration but system
    addMigration(MigrateIos13Theme())
    
    switch monitor.state {
      
    case .installed:
      addMigration(MigrateOldMediaCache())
      addMigration(MigrateDiscreteCacheLimits())
      
    case .notChanged:
      break
      
    case .upgraded(let previousVersion):
      let currentVersion = AppVersion.marketingVersion
      if currentVersion >= "1.5.0" && previousVersion < "1.5.0" {
        addMigration(MigrateShowSwipeAlert())
      }
      if currentVersion >= "1.6.1" && previousVersion < "1.6.1" {
        addMigration(MigrateMinCacheSize())
      }
      
    case .downgraded:
      break
      
    }
    
    return runMigrations()
  }
  
  private func addMigration(_ action: MigrationAction) {
    actionList.append(action)
  }
  
  private func runMigrations() -> Guarantee<Void> {
    
    guard let firstAction = actionList.first else { return Guarantee<Void>() }
    let remainingList = Array(actionList.dropFirst())
    
    return takeAndHandle(currentAction: firstAction, remainingActions: remainingList).done {
      self.actionList.removeAll()
    }
  }
  
  private func takeAndHandle(currentAction: MigrationAction, remainingActions: [MigrationAction]) -> Guarantee<Void> {
    
    return firstly {
      currentAction.migrate()
      
    }.then { _ -> Guarantee<Void> in

      guard let nextAction = remainingActions.first else {
        return Guarantee<Void>()
      }
      
      let remaining = Array(remainingActions.dropFirst())
      return self.takeAndHandle(currentAction: nextAction, remainingActions: remaining)
    }
    
  }

}
