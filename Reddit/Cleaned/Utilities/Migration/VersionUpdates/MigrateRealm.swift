//
//  MigrateRealm.swift
//  Reddit
//
//  Created by made2k on 6/9/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import Logging
import PromiseKit
import RealmSwift

/**
 Updates realm if needed.

 Upgrade Schema 0 -> 1:
 VisitedLink object had a primary key explictly added.
 */
class MigrateRealm: NSObject, MigrationAction {

  func migrate() -> Guarantee<Void> {

    let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { [unowned self] migration, oldSchemaVersion in

      if oldSchemaVersion == 0 {
        self.migrateFrom0To1(migration)
      }

    })

    Realm.Configuration.defaultConfiguration = config

    do {
      try Realm.performMigration()

    } catch {
      log.error("error performing realm migration", error: error)
    }

    return .value(())
  }

  /// VisitedLink had id property set as primary key for faster lookups
  private func migrateFrom0To1(_ migration: Migration) {

    log.info("migrating visited link primary key")

    migration.enumerateObjects(ofType: VisitedLink.className()) { (oldObject, newObject) in

      guard let oldObject = oldObject, let newObject = newObject else { return }

      newObject["id"] = oldObject["id"]
      migration.delete(oldObject)

    }

  }

}


