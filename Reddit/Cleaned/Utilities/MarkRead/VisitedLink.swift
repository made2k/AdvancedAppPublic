//
//  VisitedLink.swift
//  Reddit
//
//  Created by made2k on 10/22/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation
import RealmSwift

class VisitedLink: Object {
  @objc dynamic var id = ""
  
  convenience init(_ id: String) {
    self.init()
    self.id = id
  }

  override static func primaryKey() -> String? {
    return "id"
  }

}

