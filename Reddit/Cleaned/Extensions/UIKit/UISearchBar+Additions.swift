//
//  UISearchBar+Additions.swift
//  Reddit
//
//  Created by made2k on 12/2/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension UISearchBar {
  
  var cancelButton: UIButton? {
    return subview(of: UIButton.self, deepSearch: true)
  }
  
}
