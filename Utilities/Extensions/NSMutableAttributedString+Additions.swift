//
//  NSMutableAttributedString+Additions.swift
//  Utilities
//
//  Created by made2k on 5/16/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
  
  public func setSubstringFont(_ substring: String, font: UIFont) {
    
    let ranges = string.nsRanges(of: substring, options: [])
    
    for range in ranges {
      removeAttribute(.font, range: range)
      addAttributes([.font: font], range: range)
    }
  }
  
  public func addAttributesToSubstring(_ substring: String, attributes: [NSAttributedString.Key: Any]) {
    let ranges = string.nsRanges(of: substring, options: [])
    
    for range in ranges {
      addAttributes(attributes, range: range)
    }
    
  }
  
}
