//
//  LinkViewController+CommentNavigator.swift
//  Reddit
//
//  Created by made2k on 1/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Haptica
import UIKit

extension LinkViewController {

  func commentNavigatorButtonPressed() {

    guard let tree = model?.commentTree else { return }
    guard tree.allComments.isEmpty == false else { return }

    let viewPoint = CGPoint(x: 25, y: view.safeAreaInsets.top + 20)
    let tablePoint = tableNode.convert(viewPoint, from: node)
    var firstVisibleIndex = tableNode.indexPathForRow(at: tablePoint) ?? IndexPath(row: 0, section: 1)
    
    // If we're still showing the first section, just show the first comment
    if firstVisibleIndex.section == 0 {
      Haptic.impact(.light).generate()
      tableNode.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
      return
    }
    
    guard firstVisibleIndex.row < tree.allComments.count else { return }

    let unhiddenComments = Array(tree.allComments.suffix(from: firstVisibleIndex.row).filter { $0.hidden == false })
    
    // We must reset the first visible index since there can be hidden comments when it's first calculated.
    if let comment = unhiddenComments.first, let index = tree.allComments.firstIndex(where: { $0 === comment }) {
      firstVisibleIndex = IndexPath(row: index, section: 1)
    }
    
    // Need to make sure we can navigate down the comment tree
    guard tree.allComments.count > firstVisibleIndex.row + 1 else { return }
    
    let availableScrollComments = Array(tree.allComments.suffix(from: firstVisibleIndex.row + 1))
    
    guard let nextTopLevel = availableScrollComments.first(where: { $0.level == 0 && $0.collapsed.value == false }) else { return }
    guard let nextIndex = tree.allComments.firstIndex(where: { $0 === nextTopLevel }) else { return }

    let indexPathToScroll = IndexPath(row: nextIndex, section: 1)

    Haptic.impact(.light).generate()
    tableNode.scrollToRow(at: indexPathToScroll, at: .top, animated: true)
  }

}
