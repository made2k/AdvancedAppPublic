//
//  AppIconPickerViewController+ASTableDataSource.swift
//  Reddit
//
//  Created by made2k on 6/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension AppIconPickerViewController: ASTableDataSource {

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let item = dataSource[indexPath.row]
    return {
      AppIconCellNode(item: item)
    }
  }
  
}
