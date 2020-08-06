//
//  SwipeConfigurable.swift
//  Reddit
//
//  Created by made2k on 9/18/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

protocol SwipeConfigurable {
  
  func registerTriggers(_ manifest: TriggerType)

}

extension SwipeConfigurable {

  func createUpvoteTrigger(_ model: VoteModelType) -> SwipeTrigger {
    return UpvoteSwipeTrigger(model: model)
  }

  func createDownvoteTrigger(_ model: VoteModelType) -> SwipeTrigger {
    return DownvoteSwipeTrigger(model: model)
  }

  func createCollapseTrigger(_ model: CommentModel) -> SwipeTrigger {
    return CollapseSwipeTrigger(model: model)
  }

  func createReplyTrigger(archived: Bool, action: @escaping () -> Void) -> SwipeTrigger {
    return ReplySwipeTrigger(archived: archived, action: action)
  }

  func createRemindTrigger(type: ReminderType, body: String, url: URL) -> SwipeTrigger {
    return RemindSwipeTrigger(type: type, url: url, notificationBody: body)
  }

  func createHideTrigger(_ model: HideModelType, action: @escaping Action, onError: @escaping Action) -> SwipeTrigger {
    return HideSwipeTrigger(model: model, hideSuccess: action, onError: onError)
  }

  func createMarkReadTrigger(_ model: ReadModelType) -> SwipeTrigger {
    return MarkReadSwipeTrigger(model: model)
  }

  func createSaveTrigger(_ model: LinkModel) -> SwipeTrigger {
    return SaveSwipeTrigger(model: model)
  }
  
}
