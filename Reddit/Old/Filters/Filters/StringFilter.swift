//
//  StringFilter.swift
//  Reddit
//
//  Created by made2k on 5/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation

class StringFilter: Filter {
  
  @objc dynamic var contains: Bool = false
  @objc dynamic var query: String = ""
  
  convenience init(_ query: String, contains: Bool, subreddit: String?) {
    self.init()
    
    self.query = query.lowercasedTrim
    self.contains = contains
    self.subreddit = subreddit?.lowercasedTrim
  }
  
  func compare(source: String) -> Bool {
    let source = source.lowercasedTrim
    
    if contains {
      return source.contains(query) || source == query
    }
    
    return source == query
  }
}
