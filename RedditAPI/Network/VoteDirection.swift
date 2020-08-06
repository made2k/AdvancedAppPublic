//
//  VoteDirection.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public enum VoteDirection: Int, Decodable {
  case down = -1
  case up = 1
  case none = 0
}
