//
//  LiveCommentsSettingsViewController+ASTableDataSource.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension LiveCommentsSettingsViewController: ASTableDataSource {

  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return 2
  }

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    return indexPath.section ==  0 ? loadingAnimationRow() : refreshRow()
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ?
      R.string.settings.loadingAnimationHeader() :
      R.string.settings.refreshRateHeader()
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return section == 1 ?
      R.string.settings.refreshRateFooter() :
      nil
  }

  private func loadingAnimationRow() -> ASCellNodeBlock {
    return {
      ActivityIndicatorSelectionCellNode(title: R.string.settings.animationTypeRowText(),
                                         activity: Settings.liveCommentLoadingType,
                                         backgroundColor: .secondarySystemGroupedBackground)
    }
  }

  private func refreshRow() -> ASCellNodeBlock {
    return {
      let node = DetailLabelCellNode(.secondarySystemGroupedBackground)
      node.titleNode.text = R.string.settings.refreshIntervalRowText()
      node.detailNode.text = R.string.settings.refreshDuration(Int(Settings.liveCommentInterval))
      return node
    }
  }

}
