//
//  MessageCellNode+SwipeConfigurable.swift
//  Reddit
//
//  Created by made2k on 9/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension MessageCellNode: SwipeConfigurable {

  func registerTriggers(_ manifest: TriggerType) {
    clearTriggers()

    addTriggers(for: .state(0, .left), identifier: manifest.left1, model: model)
    addTriggers(for: .state(1, .left), identifier: manifest.left2, model: model)

    addTriggers(for: .state(0, .right), identifier: manifest.right1, model: model)
    addTriggers(for: .state(1, .right), identifier: manifest.right2, model: model)
  }

  private func addTriggers(for state: SwipeCellNodeState, identifier: TriggerIdentifier?, model: MessageModel) {

    guard let identifier = identifier else { return }

    switch identifier {

    case .markRead:
      addSwipeTrigger(for: state, trigger: createMarkReadTrigger(model))

    case .reply:
      guard model.message.kind == .message else { return }
      addSwipeTrigger(for: state, trigger: createReplyTrigger(archived: false) { [weak self] in
        self?.delegate?.didSwipeToReply(model: model)
      })

    case .collapse, .upvote, .downvote, .hide, .save, .remind:
      break
    }

  }

}
