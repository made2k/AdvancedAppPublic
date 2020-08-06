//
//  ListingsCellNode+SwipeConfigurable.swift
//  Reddit
//
//  Created by made2k on 9/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension ListingsCellNode: SwipeConfigurable {
  
  func registerTriggers(_ manifest: TriggerType) {
    clearTriggers()

    addTriggers(for: .state(0, .left), identifier: manifest.left1, model: model)
    addTriggers(for: .state(1, .left), identifier: manifest.left2, model: model)

    addTriggers(for: .state(0, .right), identifier: manifest.right1, model: model)
    addTriggers(for: .state(1, .right), identifier: manifest.right2, model: model)
  }
  
  private func addTriggers(for state: SwipeCellNodeState, identifier: TriggerIdentifier?, model: LinkModel) {

    guard let identifier = identifier else { return }

    switch identifier {
    case .upvote:
      addSwipeTrigger(for: state, trigger: createUpvoteTrigger(model))

    case .downvote:
      addSwipeTrigger(for: state, trigger: createDownvoteTrigger(model))

    case .reply:
      addSwipeTrigger(for: state, trigger: createReplyTrigger(archived: model.archived) { [weak delegate] in
        delegate?.listingCellDidStartReply(for: model)
      })
      break

    case .save:
      addSwipeTrigger(for: state, trigger: createSaveTrigger(model))

    case .hide:
      let onHidden: Action = { [weak delegate] in
        delegate?.listingsCellDidHide(for: model)
      }
      let onError: Action = { [weak self] in
        self?.swipeToOrigin()
      }
      let hideTrigger = createHideTrigger(model, action: onHidden, onError: onError)
      addSwipeTrigger(for: state, trigger: hideTrigger)

    case .markRead:
      addSwipeTrigger(for: state, trigger: createMarkReadTrigger(model))

    case .remind:
      guard let url = model.link.permalink else { return }
      let title = "\(model.link.title)"
      addSwipeTrigger(for: state, trigger: createRemindTrigger(type: .link, body: title, url: url))

    case .collapse:
      break
    }
    
  }

}
