//
//  NVActivityIndicatorNode.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import NVActivityIndicatorView

class NVActivityIndicatorNode: ASDisplayNode {

  var color: UIColor? {
    get {
      indicatorView?.color
    }
    set {
      indicatorView?.color = newValue ?? .systemGray3
    }
  }

  private var indicatorView: NVActivityIndicatorView?

  private var shouldBeAnimating = true

  // MARK: - Initialization

  init(type: NVActivityIndicatorType) {
    super.init()

    style.preferredSize = CGSize(square: 30)

    setViewBlock { [unowned self] () -> UIView in
      let color = self.color
      let view = NVActivityIndicatorView(frame: .zero, type: type, color: color, padding: nil)
      self.indicatorView = view
      return view
    }
  }

  // MARK: - Lifecycle

  override func didEnterVisibleState() {
    super.didEnterVisibleState()

    if shouldBeAnimating {
      indicatorView?.startAnimating()
    }

  }

  override func didExitVisibleState() {
    super.didExitVisibleState()
    indicatorView?.stopAnimating()
  }

  // MARK: - Functions

  func startAnimating() {
    shouldBeAnimating = true
    indicatorView?.startAnimating()
  }

  func stopAnimating() {
    shouldBeAnimating = false
    indicatorView?.stopAnimating()
  }

  func setType(_ type: NVActivityIndicatorType) {
    indicatorView?.type = type
  }

}
