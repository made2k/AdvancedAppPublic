//
//  FontSize.swift
//  Reddit
//
//  Created by made2k on 6/18/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import CoreGraphics

enum FontSize {
  
  case micro
  case small
  case `default`
  case large
  case huge
  case custom(CGFloat)
  
  var size: CGFloat {
    switch self {
    case .micro: return 12
    case .small: return 14
    case .default: return 16
    case .large: return 18
    case .huge: return 21
    case .custom(let value): return value
    }
  }
  
}
