//
//  NumberFilter.swift
//  Reddit
//
//  Created by made2k on 5/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

class NumberFilter: Filter {
  
  @objc dynamic var greaterThan: Bool = false
  @objc dynamic var number: Int = 0
  
  public convenience init(_ number: Int, greaterThan: Bool, subreddit: String?) {
    self.init()
    
    self.number = number
    self.greaterThan = greaterThan
    self.subreddit = subreddit
  }
  
  func compare(target: Int) -> Bool {
    
    if greaterThan {
      return target >= number
      
    } else {
      return target <= number
    }
  }
}
