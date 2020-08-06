//
//  BaseMediaViewController+LongPress.swift
//  Reddit
//
//  Created by made2k on 8/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension BaseMediaViewController {

  func setupLongPressGesture() {
    setupLegacyMenu()
  }

  // TODO: Use iOS 13's context menu. Need to re-adjust image view though
  private func setupLegacyMenu() {
    let longPressGesture = UILongPressGestureRecognizer { [weak self] handler in
      self?.legacyLongPressHandler(handler)
    }

    view.addGestureRecognizer(longPressGesture)
  }

  private func legacyLongPressHandler(_ gesture: UILongPressGestureRecognizer) {
    guard gesture.state == .began else { return }
    guard let image = mediaView.imageView?.image else { return }

    ImageLongPressHandler.handleLongPress(image, url: fetchedMediaUrl, gesture: gesture)
  }


}
