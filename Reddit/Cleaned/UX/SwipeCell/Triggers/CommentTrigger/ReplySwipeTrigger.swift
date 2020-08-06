//
//  ReplySwipeTrigger.swift
//  Reddit
//
//  Created by made2k on 9/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

class ReplySwipeTrigger: SwipeTrigger {

  private(set) lazy var color: UIColor = {
    return archived ? .systemGray3 : R.color.swipePurple().unsafelyUnwrapped
  }()
  let view: SwipeCellTriggerableView = ImageTriggerableView(symbol: .arrowshapeTurnUpLeft)

  let mode: SwipeCellNodeMode = .none

  private(set) lazy var block: SwipeCellNodeTriggerBlock = { [weak self] _, _, _, _ in
    guard let self = self else { return }
    
    guard self.archived == false else {
      return self.showArchivedError()
    }
    
    guard self.isSignedIn == true else {
      return self.showNotSignedInError()
    }
    
    self.action()
  }

  private let archived: Bool
  private let action: (() -> Void)

  init(archived: Bool, action: @escaping () -> Void) {
    self.archived = archived
    self.action = action
  }

}
