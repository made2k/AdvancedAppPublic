//
//  HTMLTableCoordinator+DTAttributedTextContentViewDelegate.swift
//  Reddit
//
//  Created by made2k on 2/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import DTCoreText
import Foundation

extension HTMLTableCoordinator: DTAttributedTextContentViewDelegate {

  func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewForLink url: URL!, identifier: String!, frame: CGRect) -> UIView! {

    let button = PreviewingLinkButton(frame: frame, url: url, identifier: identifier)

    button.addTargetClosure { [unowned self] in
      self.linkOpened(button: button, url: url)
    }

    button.minimumHitSize = CGSize(width: 10, height: 24)

    return button

  }

  private func linkOpened(button: DTLinkButton, url: URL) {
    LinkHandler.handleUrl(url)
  }

}
