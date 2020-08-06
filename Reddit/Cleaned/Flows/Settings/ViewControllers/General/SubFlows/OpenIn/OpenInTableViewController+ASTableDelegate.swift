//
//  OpenInTableViewController+ASTableDelegate.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension OpenInTableViewController: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {

    guard let section = Sections(rawValue: indexPath.section) else { return }

    switch section {
    case .browser: didSelectBrowser(at: indexPath.row)
    case .youtube: didSelectYouTube(at: indexPath.row)
    }

  }

  private func didSelectBrowser(at index: Int) {
    let browser = availableBrowsers[index]
    OpenInPreference.shared.browserPreference = browser
    node.reloadSection(Sections.browser.rawValue, with: .fade)
  }

  private func didSelectYouTube(at index: Int) {
    let youtube = availableYouTube[index]
    OpenInPreference.shared.youtubePreference = youtube
    node.reloadSection(Sections.youtube.rawValue, with: .fade)
  }

}
