//
//  MigrationAction.swift
//  Reddit
//
//  Created by made2k on 2/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

protocol MigrationAction {
  func migrate() -> Guarantee<Void>
}
