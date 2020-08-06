//
//  OpenInTableViewController+ASTableDataSource.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit


extension OpenInTableViewController: ASTableDataSource {

  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return Sections.allCases.count
  }

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {

    guard let section = Sections(rawValue: section) else { return 0 }

    switch section {
    case .browser: return availableBrowsers.count
    case .youtube: return availableYouTube.count
    }

  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

    guard let section = Sections(rawValue: indexPath.section) else { fatalError() }

    switch section {
    case .browser: return cellBlockForBrowser(at: indexPath.row)
    case .youtube: return cellBlockForYouTube(at: indexPath.row)
    }

  }

  private func cellBlockForBrowser(at index: Int) -> ASCellNodeBlock {

    let browser = availableBrowsers[index]
    let isSelected = OpenInPreference.shared.browserPreference == browser

    return {
      OpenInCellNode(title: browser.rawValue, isSelected: isSelected)
    }

  }

  private func cellBlockForYouTube(at index: Int) -> ASCellNodeBlock {

    let youtube = availableYouTube[index]
    let isSelected = OpenInPreference.shared.youtubePreference == youtube

    return {
      OpenInCellNode(title: youtube.rawValue, isSelected: isSelected)
    }

  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

    guard let section = Sections(rawValue: section) else { return nil }

    switch section {
    case .browser: return "Browsers"
    case .youtube: return "YouTube"
    }

  }

}
