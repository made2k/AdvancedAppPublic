//
//  SwipeCellNodeDelegate.swift
//  Reddit
//
//  Created by made2k on 9/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import CoreGraphics
import Foundation

protocol SwipeCellNodeDelegate {
  func SwipeCellNodeDidStartSwiping(_ cell: SwipableCellNode)
  func SwipeCellNodeDidFinishSwiping(_ cell: SwipableCellNode, atState state: SwipeCellNodeState, triggerActivated activated: Bool)
  func SwipeCellNode(_ cell: SwipableCellNode, didSwipeWithPercentage percentage: CGFloat, currentState state: SwipeCellNodeState, triggerActivated activated: Bool)
}
