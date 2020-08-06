//
//  GifVideoNode+UIGestureRecognizerDelegate.swift
//  Reddit
//
//  Created by made2k on 2/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension GifVideoNode: UIGestureRecognizerDelegate {

  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let gesture = gestureRecognizer as? UIPanGestureRecognizer, gesture.delegate === self else { return true }
    guard gesture.location(in: self.view).x > 50 else { return false }

    let translation = gesture.translation(in: nil)
    return abs(translation.x) > abs(translation.y) + 0.25
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return Settings.allowGifScrolling
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // This says the pan gesture does not need to fail before long press is accepted
    if gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UILongPressGestureRecognizer {
      return false
    }
    return true
  }

}
