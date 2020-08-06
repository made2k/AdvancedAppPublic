//
//  OverviewMediaViewController+TapGesture.swift
//  Reddit
//
//  Created by made2k on 8/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension OverviewMediaViewController {

  func setupTapGestures() {

    guard linkInfoView != nil else { return }

    let singleTap = UITapGestureRecognizer { [unowned self] _ in
      self.toggleInfoView()
    }
    singleTap.numberOfTapsRequired = 1
    view.addGestureRecognizer(singleTap)

    // Our mediaView has a double tap recognizer, so watch for that here
    singleTap.require(toFail: mediaView.doubleTapGesture)
  }

  private func toggleInfoView() {

    guard let infoView = linkInfoView else { return }

    let duration: TimeInterval = 0.3

    if infoView.alpha == 0 || infoView.isHidden == true {
      infoView.alpha = 0
      infoView.fadeIn(duration: duration)

    } else {
      infoView.fadeOut(duration: duration)
    }

  }
}
