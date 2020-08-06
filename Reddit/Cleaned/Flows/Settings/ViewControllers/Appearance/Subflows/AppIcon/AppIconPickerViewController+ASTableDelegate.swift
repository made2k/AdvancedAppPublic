//
//  AppIconPickerViewController+ASTableDelegate.swift
//  Reddit
//
//  Created by made2k on 6/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension AppIconPickerViewController: ASTableDelegate {
  
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let item = dataSource[indexPath.row]
    delegate?.didSelectAppIcon(item)
  }
  
}
