//
//  DTCoreTextNode+Size.swift
//  Reddit
//
//  Created by made2k on 8/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import DTCoreText

extension DTCoreTextNode {

  override func calculateLayoutThatFits(_ constrainedSize: ASSizeRange, restrictedTo size: ASLayoutElementSize, relativeToParentSize parentSize: CGSize) -> ASLayout {

    let empty = ASLayout(layoutElement: self, size: .zero)

    let constrained = max(constrainedSize.max.width, parentSize.width).clamped(to: 5...1000)

    let hasMaxHeightConstraint = ASDimensionEqualToDimension(style.maxLayoutSize.height, ASDimensionAuto) == false &&
      style.maxLayoutSize.height.unit == .points

    let maxHeight: CGFloat? = hasMaxHeightConstraint ? style.maxLayoutSize.height.value : nil

    guard let size = calculateSize(fitting: constrained, maxHeight: maxHeight) else { return empty }

    return ASLayout(layoutElement: self, size: size)
  }

  func calculateSize(fitting width: CGFloat, maxHeight: CGFloat?) -> CGSize? {
    guard let attributedText = attributedText, !attributedText.string.isEmpty else { return nil }
    guard let layouter = DTCoreTextLayouter(attributedString: attributedText) else { return nil }

    let entireString = attributedText.nsRange
    let maxRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(CGFLOAT_HEIGHT_UNKNOWN))

    guard let frame = layouter.layoutFrame(with: maxRect, range: entireString) else { return nil }

    let size = CGSize(width: frame.frame.width, height: min(frame.frame.height, (maxHeight ?? .greatestFiniteMagnitude)))
    return size
  }

}
