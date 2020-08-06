//
//  LiveCommentSelectionViewController+ASTableDelegate.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension LiveCommentSelectionViewController: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let type = datasource[indexPath.row]
    delegate?.didSelectIndicator(type)
  }
}

