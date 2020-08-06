//
//  SwipeCellNodeTrigger.swift
//  Reddit
//
//  Created by made2k on 9/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

class SwipeCellNodeTrigger {

  var mode: SwipeCellNodeMode
  var color: UIColor
  var view: SwipeCellTriggerableView
  var block: SwipeCellNodeTriggerBlock?

  init(mode: SwipeCellNodeMode, color: UIColor, view: SwipeCellTriggerableView, block: SwipeCellNodeTriggerBlock?) {
    self.mode = mode
    self.color = color
    self.view = view
    self.block = block
  }

  func executeTriggerBlock(withSwipeCellNode cell: SwipableCellNode, state: SwipeCellNodeState) {
    block?(cell, self, state, mode)
  }
}
