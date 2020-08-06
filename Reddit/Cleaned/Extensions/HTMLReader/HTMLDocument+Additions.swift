//
//  HTMLDocument+Additions.swift
//  Reddit
//
//  Created by made2k on 2/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import HTMLReader

extension HTMLDocument {

  /// Returns the first node matching "table"
  var table: HTMLElement? {
    return firstNode(matchingSelector: "table")
  }

}
