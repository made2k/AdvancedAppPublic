//
//  ASTableNode+Additions.swift
//  Reddit
//
//  Created by made2k on 1/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import SwiftReorder

extension ASTableNode {

  // MARK: - Properties

  var keyboardDismissMode: UIScrollView.KeyboardDismissMode {
    get {
      return view.keyboardDismissMode
    }
    set {
      onDidLoad { [weak self] _ in
        self?.view.keyboardDismissMode = newValue
      }
    }
  }

  var refreshControl: UIRefreshControl? {
    get {
      return view.refreshControl
    }
    set {
      onDidLoad { [weak self] _ in
        self?.view.refreshControl = newValue
      }
    }
  }

  var separatorStyle: UITableViewCell.SeparatorStyle {
    get {
      return view.separatorStyle
    }
    set {
      onDidLoad { [weak self] _ in
        self?.view.separatorStyle = newValue
      }
    }
  }

  var reorderDelegate: TableViewReorderDelegate? {
    get {
      return view.reorder.delegate
    }
    set {
      onDidLoad { [weak self] _ in
        self?.view.reorder.delegate = newValue
      }
    }
  }

  // MARK: - Functions

  func addPullToRefresh(_ handler: @escaping (UIRefreshControl) -> Void) {
    let refreshControl = UIRefreshControl(handler: handler)
    self.refreshControl = refreshControl
  }

  func hideEmptyCells() {
    onDidLoad { [weak self] _ in
      self?.view.hideEmptyCells()
    }
  }

  func reloadData(maintainScrollPosition: Bool) {

    guard maintainScrollPosition else { return reloadData() }

    guard let firstIndex = indexPathsForVisibleRows().min() else { return reloadData() }

    reloadData { [weak self] in
      self?.scrollToRow(at: firstIndex, at: .top, animated: false)
    }

  }

  func reloadSection(_ section: Int, with animation: UITableView.RowAnimation) {
    reloadSections([section], with: animation)
  }

  // MARK: - Subnodes

  func node(at point: CGPoint) -> ASDisplayNode {

    guard
      let indexPath = indexPathForRow(at: point),
      let node = nodeForRow(at: indexPath) else {
        return self
    }

    return node

  }

}
