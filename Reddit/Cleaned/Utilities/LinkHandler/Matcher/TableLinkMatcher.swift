//
//  TableLinkMatcher.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

struct TableLinkMatcher {

  static func match(_ url: URL) -> String? {

    guard let tableData = url.host else { return nil }

    if url.scheme == URL.CustomSchemes.table {
      return tableData
    }

    return nil

  }

}
