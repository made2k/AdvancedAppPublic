//
//  ReplyCreationModel.swift
//  Reddit
//
//  Created by made2k on 9/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI

class ReplyCreationModel: ViewModel {
  
  private let parentName: String
  let parentHtml: String?
  
  var title: String {
    guard let parentType = DataKind.type(from: parentName) else { return "" }
    
    switch parentType {
    case .link:
      return R.string.replyCreate.titleAddComment()
    case .comment:
      return R.string.replyCreate.titleCommentReply()
    case .message:
      return R.string.replyCreate.titleMessageReply()
    default:
      return ""
    }
    
  }
  
  init(parentName: String, parentHtml: String?) {
    self.parentName = parentName
    self.parentHtml = parentHtml
  }
  
  // MARK: - Auto save
  
  func autoSave(_ text: String) {
    AutoSaveManager.shared.saveReply(parentName: parentName,
                                     text: text,
                                     parentText: parentHtml)
  }
  
  // MARK: - Saving
  
  func saveComment(_ text: String) -> Promise<Comment> {
    return api.session.submitComment(parentName: parentName, body: text)
  }
  
  func saveMessage(_ text: String) -> Promise<Message> {
    return api.session.submitMessage(parentName: parentName, body: text)
  }

}
