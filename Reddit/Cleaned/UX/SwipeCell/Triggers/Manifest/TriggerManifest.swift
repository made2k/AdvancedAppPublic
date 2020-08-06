//
//  TriggerManifest.swift
//  Reddit
//
//  Created by made2k on 9/18/19.
//  Copyright © 2019 made2k. All rights reserved.
//

struct TriggerManifest {
  
  var listing: TriggerType
  var comment: TriggerType
  var message: TriggerType
  
  static func defaultManafest() -> TriggerManifest {

    let listing = TriggerType(left1: .upvote, left2: .downvote,
                              right1: .save, right2: .hide)
    
    let comment = TriggerType(left1: .upvote, left2: .downvote,
                              right1: .collapse, right2: .reply)
    
    let message = TriggerType(left1: .markRead, left2: nil,
                              right1: .reply, right2: nil)
    
    return TriggerManifest(listing: listing, comment: comment, message: message)
  }
  
}

extension TriggerManifest: Codable { }
