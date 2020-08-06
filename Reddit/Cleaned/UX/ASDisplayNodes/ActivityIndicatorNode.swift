//
//  ActivityIndicatorNode.swift
//  Reddit
//
//  Created by made2k on 2/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import UIKit

final class ActivityIndicatorNode: ASDisplayNode {

  private(set) var activityIndicator: UIActivityIndicatorView?

  init(style: UIActivityIndicatorView.Style) {

    super.init()

    self.style.preferredSize = CGSize(width: 25, height: 25)

    self.setViewBlock { () -> UIView in
      let indicator = UIActivityIndicatorView(style: style)
      indicator.hidesWhenStopped = false
      self.activityIndicator = indicator
      return indicator
    }

  }

  override func didEnterVisibleState() {
    super.didEnterVisibleState()
    activityIndicator?.startAnimating()
  }

  override func didExitVisibleState() {
    super.didExitVisibleState()
    activityIndicator?.stopAnimating()
  }

}
