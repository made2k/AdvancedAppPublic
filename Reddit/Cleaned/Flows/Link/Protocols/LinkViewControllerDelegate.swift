//
//  LinkViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 1/12/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit

protocol LinkViewControllerDelegate: class, ASTableDataSource, ASTableDelegate, ASTextNodeDelegate {

  /// Clears the focus and reloads the comments
  @discardableResult
  func clearFocus() -> Promise<Void>
  @discardableResult
  func loadComments() -> Promise<Void>

  func showSortSelection()

  func viewDidDisappear()
}
