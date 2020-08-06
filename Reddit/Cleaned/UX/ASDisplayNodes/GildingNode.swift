//
//  GildingNode.swift
//  Reddit
//
//  Created by made2k on 6/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI

class GildingNode: ASDisplayNode {

  private lazy var platinumNode = CircularNode(color: UIColor(hex: 0x07d3bb))
  private lazy var goldNode = CircularNode(color: UIColor(hex: 0xe2be32))
  private lazy var silverNode = CircularNode(color: UIColor(hex: 0xc8c8c8))

  private let platinum: Int
  private let gold: Int
  private let silver: Int

  var hasBeenGilded: Bool {
    return platinum > 0 || gold > 0 || silver > 0
  }

  init(gildings: Gildings) {
    self.platinum = gildings.platinum
    self.gold = gildings.gold
    self.silver = gildings.silver

    super.init()
    commonInit()
  }

  private func commonInit() {
    automaticallyManagesSubnodes = true
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    guard hasBeenGilded else { return ASLayoutSpec() }

    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.spacing = 1

    var children: [ASLayoutElement] = []

    if platinum > 0 {
      children.append(platinumNode)
    }

    if gold > 0 {
      children.append(goldNode)
    }

    if silver > 0 {
      children.append(silverNode)
    }

    if children.count == 2 {
      children.insert(ASLayoutSpec.spacer(), at: 1)
    }

    if children.count == 3 {
      children.insert(ASLayoutSpec.spacer(), at: 2)
      children.insert(ASLayoutSpec.spacer(), at: 1)
    }

    children.prepend(ASLayoutSpec.spacer())
    children.append(ASLayoutSpec.spacer())

    verticalSpec.children = children

    return verticalSpec
  }

  private func wrapCircle(_ node: ASDisplayNode) -> ASLayoutSpec {
    return ASRatioLayoutSpec(ratio: 1, child: node)
  }

}

private class CircularNode: ASDisplayNode {

  override var frame: CGRect {
    didSet {
      let size = frame.width
      cornerRadius = size / 2
    }
  }

  init(color: UIColor?) {
    super.init()
    self.backgroundColor = color
  }

  override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
    let minConstraint = min(constrainedSize.width, constrainedSize.height)
    let size = min(minConstraint, 5)
    return CGSize(square: size)
  }

}
