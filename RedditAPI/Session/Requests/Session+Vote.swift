//
//  Session+Vote.swift
//  RedditAPI
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

extension Session {

  public func setVote(thing: VoteType, direction: VoteDirection) -> Promise<Void> {

    controller.requestVoid(.vote(direction, thing: thing))
    
  }

}
