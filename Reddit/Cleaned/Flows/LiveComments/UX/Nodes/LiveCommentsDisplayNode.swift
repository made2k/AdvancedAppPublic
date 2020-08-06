//
//  LiveCommentsDisplayNode.swift
//  Reddit
//
//  Created by made2k on 9/3/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import Then

/// The node responsible for housing the display of
/// the live mode feature.
final class LiveCommentsDisplayNode: ASDisplayNode {

  let tableNode = ASTableNode(style: .plain).then {
    $0.backgroundColor = .systemBackground
    $0.hideEmptyCells()
  }
  private lazy var replyNode: LiveCommentEntryNode = .init(delegate: delegate)

  private var isSignedIn: Bool {
    return AccountModel.currentAccount.value.isSignedIn
  }

  private let delegate: LiveCommentViewControllerDelegate
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  init(delegate: LiveCommentViewControllerDelegate) {

    self.delegate = delegate

    super.init()

    automaticallyManagesSubnodes = true

    tableNode.inverted = isSignedIn
    tableNode.style.flexGrow = 1
    tableNode.automaticallyAdjustsContentOffset = true

    tableNode.dataSource = delegate
    tableNode.delegate = delegate
  }

  // MARK: - Lifecycle
  
  override func didLoad() {
    super.didLoad()

    tableNode.view.tableHeaderView = LiveModeLoadingView()
    tableNode.view.contentInsetAdjustmentBehavior = isSignedIn ? .never : .automatic

    if isSignedIn {
      let navigationHeight: CGFloat = closestViewController?.navigationController?.navigationBar.frame.height ?? 44
      let topInset: CGFloat = view.statusBarHeight + navigationHeight
      tableNode.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: topInset, right: 0)
    }
  }

  // MARK: - Layout

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let vertical = ASStackLayoutSpec.vertical()
    vertical.children = [tableNode]
    if isSignedIn {
      vertical.children?.append(replyNode)
    }
    return vertical
  }
}
