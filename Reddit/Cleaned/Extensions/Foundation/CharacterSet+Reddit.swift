//
//  CharacterSet+Reddit.swift
//  Reddit
//
//  Created by made2k on 6/5/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

extension CharacterSet {

  static let subredditQuery = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
  static let userQuery = subredditQuery.union(CharacterSet(charactersIn: "-"))
  
}
