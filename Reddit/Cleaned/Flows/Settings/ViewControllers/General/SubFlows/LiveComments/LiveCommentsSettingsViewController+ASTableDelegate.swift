//
//  LiveCommentsSettingsViewController+ASTableDelegate.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Logging

extension LiveCommentsSettingsViewController: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {

    if indexPath.section == 0 {
      didSelectAnimationRow(indexPath)

    } else {
      didSelectIntervalRow(indexPath)
    }

  }

  private func didSelectAnimationRow(_ indexPath: IndexPath) {

    guard let node = node.nodeForRow(at: indexPath) as? ActivityIndicatorSelectionCellNode else {
      log.error("unexpected cell type")
      return
    }

    delegate?.didSelectToUpdateAnimation(updating: node.indicator)
  }

  private func didSelectIntervalRow(_ indexPath: IndexPath) {

    guard let node = node.nodeForRow(at: indexPath) as? DetailLabelCellNode else {
      log.error("unexpected cell type")
      return
    }

    delegate?.didSelectToUpdateInterval(updating: node.detailNode)
  }

}
