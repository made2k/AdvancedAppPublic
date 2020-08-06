//
//  LinkCoordinator+ASTextNodeDelegate.swift
//  Reddit
//
//  Created by made2k on 1/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension LinkCoordinator: ASTextNodeDelegate {

  func textNode(_ textNode: ASTextNode!, shouldHighlightLinkAttribute attribute: String!, value: Any!, at point: CGPoint) -> Bool {
    return true
  }

  func textNode(_ textNode: ASTextNode!, tappedLinkAttribute attribute: String!, value: Any!, at point: CGPoint, textRange: NSRange) {
    guard let url = value as? URL else { return }
    LinkHandler.handleUrl(url)
  }

}
