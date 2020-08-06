//
//  UIFont+Additions.swift
//  Reddit
//
//  Created by made2k on 1/16/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Utilities
import UIKit

extension UIFont {
  
  var semibold: UIFont {
    if UIFont.systemFont(ofSize: pointSize).familyName == familyName {
      return UIFont.systemFont(ofSize: pointSize, weight: UIFont.Weight.semibold)
    }
    
    if let font = UIFont(name: "\(familyName)-Semibold", size: pointSize) {
      return font
    }
    
    return bold
  }

  var bold: UIFont {
    guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
    return UIFont(descriptor: descriptor, size: pointSize)
  }
  
  var light: UIFont {
    if UIFont.systemFont(ofSize: pointSize).familyName == familyName {
      return UIFont.systemFont(ofSize: pointSize, weight: UIFont.Weight.light)
    }
    
    if let font = UIFont(name: "\(familyName)-Light", size: pointSize) {
      return font
    }
    
    return self
  }

  var italic: UIFont {
    guard let descriptor = fontDescriptor.withSymbolicTraits(.traitItalic) else { return self }
    return UIFont(descriptor: descriptor, size: pointSize)
  }

}
