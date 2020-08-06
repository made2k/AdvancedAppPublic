//
//  UserSubreddit.swift
//  Reddit
//
//  Created by made2k on 6/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

enum UserSubreddit: String {
  case front = ""
  case popular = "popular"
  case all = "all"
  case random = "random"
  
  static func fromPath(_ path: String) -> UserSubreddit? {
    // Front seems to be a special case, it's path is empty, but favorites will still reference it
    if path == "front" { return .front }
    return UserSubreddit(rawValue: path)
  }

  static func isUserSubreddit(_ path: String) -> Bool {
    return fromPath(path) != nil
  }
  
  var path: String {
    return rawValue
  }
  
  var displayName: String {
    switch self {
    case .front: return "front"
    case .all: return "all"
    case .popular: return "popular"
    case .random: return "Random"
    }
  }
  
}
