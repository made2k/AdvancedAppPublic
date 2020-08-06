//
//  Operators.swift
//  Reddit
//
//  Created by made2k on 9/12/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit

import Utilities

infix operator ~==

func ~==(lhs: String, rhs: String?) -> Bool {
  guard let rhs = rhs else {
    return false
  }
  return lhs.lowercasedTrim == rhs.lowercasedTrim
}

func +(lhs: String, rhs: String?) -> String {
  if let rhs = rhs {
    return lhs + rhs
  }
  return lhs
}
