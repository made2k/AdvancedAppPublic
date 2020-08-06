//
//  NSAttributedString+Additions.swift
//  Utilities
//
//  Created by made2k on 5/16/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

extension NSAttributedString {
  
  public var nsRange: NSRange {
    return NSRange(location: 0, length: length)
  }
  
}
