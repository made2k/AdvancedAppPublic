//
//  BaseMediaViewController+Dismissing.swift
//  Reddit
//
//  Created by made2k on 8/10/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import SwifterSwift
import UIKit

// MARK: - Properties

extension BaseMediaViewController {

  private struct AssociatedKeys {
    static var panGesture: UInt8 = 0
    static var animator: UInt8 = 0
  }

  private var dismissGesture: UIPanGestureRecognizer? {
    get {
      objc_getAssociatedObject(self, &AssociatedKeys.panGesture) as? UIPanGestureRecognizer
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.panGesture, newValue, .OBJC_ASSOCIATION_ASSIGN)
    }
  }

  private var animator: UIDynamicAnimator? {
    get {
      objc_getAssociatedObject(self, &AssociatedKeys.animator) as? UIDynamicAnimator
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.animator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

}

// MARK: - Dismiss Gesture

extension BaseMediaViewController {

  func setupDismissGesture() {

    guard dismissGesture == nil else { return }

    let gesture = UIPanGestureRecognizer { [weak self] in
      self?.handlePan(gesture: $0)
    }
    self.dismissGesture = gesture

    gesture.delegate = self

    view.addGestureRecognizer(gesture)

    animator = UIDynamicAnimator(referenceView: view)
  }

  private func handlePan(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: nil)
    // Total is how much we've actually moved from original point.
    let total = abs(translation.x) + abs(translation.y)
    // Progress, not currently calculated helps dtermine cancel vs finish.
    let progress = total / 2 / view.bounds.height

    switch gesture.state {
    case .began:
      swipeDismissDidBegin()
      mediaView.gifView?.pause()
      animator?.removeAllBehaviors()

    case .changed:
      mediaView.center = view.center + translation

    default:
      animator?.removeAllBehaviors()

      // Threshold for velocity to actually launch vs just dismiss
      let throwThreshold: CGFloat = 1000
      let throwPadding: CGFloat = 5

      let velocity = gesture.velocity(in: view)
      let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))

      // If we haven't moved far enough, just reset position to center
      if progress < 0.1 && magnitude < throwThreshold {
        mediaView.gifView?.resume()
        swipeDismissDidCancel()

        UIView.animate(withDuration: 0.2) {
          self.mediaView.center = self.view.center
        }

      } else if magnitude > throwThreshold {
        // Are we "throwing" this view before animating

        let pushBehavior = UIPushBehavior(items: [mediaView], mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: velocity.x / 1, dy: velocity.y / 1)
        pushBehavior.magnitude = magnitude / throwPadding

        animator?.addBehavior(pushBehavior)

        let itemBehavior = UIDynamicItemBehavior(items: [mediaView])
        itemBehavior.friction = 0.4
        animator?.addBehavior(itemBehavior)

        UIView.animate(withDuration: 0.22, animations: {
          self.mediaView.alpha = 0

        }, completion: { _ in
          self.mediaView.isHidden = true
          self.dismiss()
        })

      } else {
        self.dismiss()
      }
    }
  }

}

// MARK: - UIGestureRecognizerDelegate

extension BaseMediaViewController: UIGestureRecognizerDelegate {

  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

    guard gestureRecognizer === dismissGesture else {
      return true
    }
    guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
    guard mediaView.zoomScale == mediaView.minimumZoomScale else { return false }

    // If we have a gif player, only activate dismiss if vertical swipe
    // so as to not interfere with gif scrobble.
    if mediaView.gifView != nil {
      let translation = panGesture.translation(in: nil)
      return abs(translation.y) > abs(translation.x)

    } else {
      return true
    }

  }
}
