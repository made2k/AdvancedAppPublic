//
//  CommentCellNode+Swipe.swift
//  Reddit
//
//  Created by made2k on 9/18/19.
//  Copyright © 2019 made2k. All rights reserved.
//

extension CommentCellNode: SwipeConfigurable {
  
  func registerTriggers(_ manifest: TriggerType) {
    clearTriggers()
    
    guard let model = model as? CommentModel else { return }

    addTriggers(for: .state(0, .left), identifier: manifest.left1, model: model)
    addTriggers(for: .state(1, .left), identifier: manifest.left2, model: model)

    addTriggers(for: .state(0, .right), identifier: manifest.right1, model: model)
    addTriggers(for: .state(1, .right), identifier: manifest.right2, model: model)
    
  }
  
  private func addTriggers(for state: SwipeCellNodeState, identifier: TriggerIdentifier?, model: CommentModel) {

    guard let identifier = identifier else { return }
    
    switch identifier {
    case .upvote:
      addSwipeTrigger(for: state, trigger: createUpvoteTrigger(model))
      
    case .downvote:
      addSwipeTrigger(for: state, trigger: createDownvoteTrigger(model))
      
    case .reply:
      guard let replyAction = replyAction else { break }
      addSwipeTrigger(for: state, trigger: createReplyTrigger(archived: model.archived, action: replyAction))
      
    case .collapse:
      addSwipeTrigger(for: state, trigger: createCollapseTrigger(model))
      
    case .remind:
      let title = model.comment.body
      let url = model.comment.permaLink
      addSwipeTrigger(for: state, trigger: createRemindTrigger(type: .comment, body: title, url: url))
      
    case .save, .hide, .markRead: break
    }
    
  }

}
