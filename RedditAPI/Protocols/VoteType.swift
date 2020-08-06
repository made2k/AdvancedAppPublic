//
//  VoteType.swift
//  RedditAPI
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public protocol VoteType: Thing {

  var score: Int { get }
  var direction: VoteDirection { get }

}
