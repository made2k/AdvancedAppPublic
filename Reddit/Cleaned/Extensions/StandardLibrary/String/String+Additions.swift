//
//  String+Additions.swift
//  Reddit
//
//  Created by made2k on 6/5/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

extension String {
  
  func removingCharacters(in set: CharacterSet) -> String {
    return self.components(separatedBy: set).joined()
  }

}
