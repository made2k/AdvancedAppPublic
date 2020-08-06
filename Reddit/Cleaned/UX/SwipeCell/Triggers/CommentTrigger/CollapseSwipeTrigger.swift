//
//  CollapseSwipeTrigger.swift
//  Reddit
//
//  Created by made2k on 9/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

class CollapseSwipeTrigger: SwipeTrigger {

  let color: UIColor = R.color.advancedBlue().unsafelyUnwrapped
  let view: SwipeCellTriggerableView = ImageTriggerableView(symbol: .arrowUpToLine)

  let mode: SwipeCellNodeMode = .toggle

  private(set) lazy var block: SwipeCellNodeTriggerBlock = { [weak self] _, _, _, _ in
    guard let self = self else { return }
    self.model.topComment.collapsed.accept(true)
  }

  private let model: CommentModel

  init(model: CommentModel) {
    self.model = model
  }

}
