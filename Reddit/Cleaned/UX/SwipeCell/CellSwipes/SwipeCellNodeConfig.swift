//
//  SwipeCellNodeConfig.swift
//  Reddit
//
//  Created by made2k on 9/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

fileprivate struct Defaults {
  static let stop1: CGFloat               = 0.26  // Percentage limit to trigger the first action
  static let stop2: CGFloat               = 0.51  // Percentage limit to trigger the second action
  static let stop3: CGFloat               = 0.69  // Percentage limit to trigger the third action
  static let swipeViewPadding: CGFloat    = 24.0  // Padding of the swipe view (space between cell and swipe view)
  static let shouldAnimateSwipeViews      = true
}

class SwipeCellNodeConfig: SwipeNodeTriggerPointEditable {
  static let shared = SwipeCellNodeConfig()

  var triggerPoints: [CGFloat: SwipeCellNodeState]
  var swipeViewPadding: CGFloat
  var shouldAnimateSwipeViews: Bool

  init() {
    triggerPoints = [:]
    triggerPoints[Defaults.stop1] = .state(0, .left)
    triggerPoints[Defaults.stop2] = .state(1, .left)
    triggerPoints[Defaults.stop3] = .state(2, .left)
    triggerPoints[-Defaults.stop1] = .state(0, .right)
    triggerPoints[-Defaults.stop2] = .state(1, .right)
    triggerPoints[-Defaults.stop3] = .state(2, .right)

    swipeViewPadding = Defaults.swipeViewPadding
    shouldAnimateSwipeViews = Defaults.shouldAnimateSwipeViews
  }
}
