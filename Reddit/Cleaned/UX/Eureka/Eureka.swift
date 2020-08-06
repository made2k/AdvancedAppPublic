//
//  Eureka.swift
//  Reddit
//
//  Created by made2k on 5/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Eureka

class Eureka: NSObject {

  static func registerDefaultCellUpdates() {

    LabelRow.defaultCellUpdate = { cell, _ in
      cell.backgroundColor = .systemBackground
      cell.selectionStyle = .none
      cell.textLabel?.textColor = .label
      cell.textLabel?.font = Settings.fontSettings.fontValue
    }

    SwitchRow.defaultCellUpdate = { cell, _ in
      cell.backgroundColor = .systemBackground
      cell.selectionStyle = .none
      cell.textLabel?.textColor = .label
      cell.textLabel?.font = Settings.fontSettings.fontValue
    }

    IconRow.defaultCellUpdate = { cell, _ in
      cell.backgroundColor = .systemBackground
      cell.selectionStyle = .none
      cell.label.textColor = .label
      cell.label.font = Settings.fontSettings.fontValue
    }

    ListCheckRow<Bool>.defaultCellUpdate = { cell, _ in
      cell.backgroundColor = .systemBackground
      cell.selectionStyle = .none
      cell.textLabel?.textColor = .label
      cell.textLabel?.font = Settings.fontSettings.fontValue
    }

  }

}
