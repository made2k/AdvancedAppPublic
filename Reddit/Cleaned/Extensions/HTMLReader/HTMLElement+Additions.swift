//
//  HTMLElement+Additions.swift
//  Reddit
//
//  Created by made2k on 2/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import HTMLReader

extension HTMLElement {

  /**
   Traverse through all child elements searching for an HTMLElement
   matching the given selector. If none are found, move to the
   child elements and search again until something is found.
   */
  func deepChildrenMatching(selector: String) -> [HTMLElement] {
    var children: [HTMLElement] = []

    if nodes(matchingSelector: selector).isEmpty {
      for child in childElementNodes {
        children += child.deepChildrenMatching(selector: selector)
      }
    } else {
      children = nodes(matchingSelector: selector)
    }

    return children
  }

  /// Get Non-Empty nodes matching "thead.th"
  var tableHeadElements: [HTMLElement]? {

    let tableHead = firstNode(matchingSelector: "thead")

    guard let nodes = tableHead?.deepChildrenMatching(selector: "th") else { return nil }
    guard nodes.isNotEmpty else { return nil }
    guard nodes.map({ $0.innerHTML }).contains(where: { $0.isNotEmpty }) else { return nil }

    return nodes
  }

  /// Get nodes matching "tbody"
  var bodyElement: HTMLElement? {
    return firstNode(matchingSelector: "tbody")
  }

  /// Get nodes matching "tr"
  var tableRowElements: [HTMLElement] {
    return nodes(matchingSelector: "tr")
  }

  /// Get nodes matching "td"
  var tableDataElements: [HTMLElement] {
    return nodes(matchingSelector: "td")
  }

}
