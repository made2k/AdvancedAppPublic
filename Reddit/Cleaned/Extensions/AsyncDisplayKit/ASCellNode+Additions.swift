//
//  ASCellNode+Additions.swift
//  Reddit
//
//  Created by made2k on 1/5/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension ASCellNode {

  /// Attempt to find the table view that houses this cell.
  /// Must be called from the main thread
  var tableNode: ASTableNode? {

    guard let controller = closestViewController as? ASViewController else { return nil }
    guard let indexPath = indexPath else { return nil }
    
    
    let tables: [ASTableNode] = ([controller.node as? ASTableNode] +
      controller.node.subnodes(of: ASTableNode.self))
      .compactMap { $0 }

    for table in tables where table.nodeForRow(at: indexPath) == self {
      return table
    }
    
    return nil

  }

}
