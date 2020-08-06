//
//  SwipeNodeTriggerPointEditable.swift
//  Reddit
//
//  Created by made2k on 9/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

protocol SwipeNodeTriggerPointEditable: class {

  var triggerPoints: [CGFloat: SwipeCellNodeState] { get set }

  func setTriggerPoint(forState state: SwipeCellNodeState, at point: CGFloat)
  func setTriggerPoint(forIndex index: Int, at point: CGFloat)
  func setTriggerPoints(_ points: [CGFloat: SwipeCellNodeState])
  func setTriggerPoints(_ points: [CGFloat: Int])
  func setTriggerPoints(points: [CGFloat])
  func getTriggerPoints() -> [CGFloat: SwipeCellNodeState]
  func clearTriggerPoints()

}

extension SwipeNodeTriggerPointEditable {

  func setTriggerPoint(forState state: SwipeCellNodeState, at point: CGFloat) {
    var p = abs(point)
    if case .state(_, let direction) = state, direction == .right {
      p = -p
    }
    triggerPoints[p] = state
  }

  func setTriggerPoint(forIndex index: Int, at point: CGFloat) {
    let p = abs(point)
    triggerPoints[p] = SwipeCellNodeState.state(index, .left)
    triggerPoints[-p] = SwipeCellNodeState.state(index, .right)
  }

  func setTriggerPoints(_ points: [CGFloat: SwipeCellNodeState]) {
    triggerPoints = points
  }

  func setTriggerPoints(_ points: [CGFloat: Int]) {
    triggerPoints = [:]
    _ = points.map { point, index in
      let p = abs(point)
      triggerPoints[p] = SwipeCellNodeState.state(index, .left)
      triggerPoints[-p] = SwipeCellNodeState.state(index, .right)
    }
  }

  func setTriggerPoints(points: [CGFloat]) {
    triggerPoints = [:]
    for (index, point) in points.enumerated() {
      let p = abs(point)
      triggerPoints[p] = SwipeCellNodeState.state(index, .left)
      triggerPoints[-p] = SwipeCellNodeState.state(index, .right)
    }
  }

  func getTriggerPoints() -> [CGFloat: SwipeCellNodeState] {
    return triggerPoints
  }

  func clearTriggerPoints() {
    triggerPoints = [:]
  }
}
