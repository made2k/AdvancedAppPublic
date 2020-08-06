//
//  SwipeCellNodeState.swift
//  Reddit
//
//  Created by made2k on 9/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

enum SwipeCellNodeState: Hashable {
  case none
  case state(Int, SwipeCellNodeDirection)

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.toInt())
  }

  static public func ==(lhs: SwipeCellNodeState, rhs: SwipeCellNodeState) -> Bool {
    return lhs.toInt() == rhs.toInt()
  }

  private func toInt() -> Int {
    switch self {
    case .none:
      return 0
    case .state(let stateNum, let stateDirection):
      // add one because state(0,...) would always be 0
      if stateDirection == .left {
        return stateNum + 1
      } else if stateDirection == .right {
        return -(stateNum + 1)
      }
    }

    return 0
  }
}
