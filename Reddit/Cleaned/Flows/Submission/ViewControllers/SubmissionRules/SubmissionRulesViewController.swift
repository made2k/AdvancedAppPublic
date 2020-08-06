//
//  SubmissionRulesViewController.swift
//  Reddit
//
//  Created by made2k on 1/30/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import AsyncDisplayKit
import DTCoreText

final class SubmissionRulesViewController: ASViewController<ASDisplayNode> {

  private let scrollNode: ASScrollNode = ASScrollNode()
  private let textNode: DTCoreTextNode = DTCoreTextNode()

  // MARK: - Initialization

  init(html: String) {

    let node: ASDisplayNode = ASDisplayNode()
    node.backgroundColor = .systemBackground
    node.automaticallyManagesSubnodes = true

    scrollNode.automaticallyManagesContentSize = true
    scrollNode.automaticallyManagesSubnodes = true
    scrollNode.automaticallyRelayoutOnSafeAreaChanges = true
    scrollNode.automaticallyRelayoutOnLayoutMarginsChanges = true

    textNode.html = html

    super.init(node: node)

    node.layoutSpecBlock = { [unowned self] (node: ASDisplayNode, sizeRange: ASSizeRange) -> ASLayoutSpec in
      return self.nodeLayout(node, sizeRange: sizeRange)
    }

    scrollNode.layoutSpecBlock = { [unowned self] (node: ASDisplayNode, sizeRange: ASSizeRange) -> ASLayoutSpec in
      return self.scrollLayout(node, sizeRange: sizeRange)
    }

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  private func nodeLayout(_ node: ASDisplayNode, sizeRange: ASSizeRange) -> ASLayoutSpec {
    let stack = ASStackLayoutSpec.vertical()
    stack.children = [scrollNode, ASLayoutSpec.spacer()]

    return stack
  }

  private func scrollLayout(_ node: ASDisplayNode, sizeRange: ASSizeRange) -> ASLayoutSpec {
    let insets: UIEdgeInsets = UIEdgeInsets(
      top: 16,
      left: 16,
      bottom: 32,
      right: 16)

    return ASInsetLayoutSpec(insets: insets, child: textNode)
  }

}
