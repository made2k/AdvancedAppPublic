//
//  UIView+Additions.swift
//  Reddit
//
//  Created by made2k on 9/17/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit

extension UIView {

  // MARK: - Display

  func fadeOutAndRemove(duration: TimeInterval = 0.4) {

    fadeOut(duration: duration) { [unowned self] _ in
      self.removeFromSuperview()
    }

  }

  // MARK: - Helpers

  func contains(_ point: CGPoint) -> Bool {
    return frame.contains(point)
  }

  func frameInWindow() -> CGRect {
    guard let window = self.window else { return frame }

    var translatedFrame = frame
    var superview = self.superview
    var currentView = self

    while let view = superview {
      translatedFrame = view.convert(translatedFrame, from: currentView)

      currentView = view
      superview = view.superview
    }

    let targetFrame = window.convert(translatedFrame, from: currentView)

    return targetFrame
  }

  var statusBarHeight: CGFloat {
    window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0
  }

  // MARK: - Subviews
  
  func containsSubview(_ targetView: UIView, deepSearch: Bool) -> Bool {
    
    let subviews = self.subviews

    // Attempt to find the target view at the top level
    if subviews.contains(where: { targetView === $0 }) {
      return true
    }
    
    guard deepSearch else { return false }

    // If we're deep searching and haven't found our target view,
    // search the subviews of our subview
    for subview in subviews {

      if subview.containsSubview(targetView, deepSearch: true) {
        return true
      }

    }
    
    return false
  }

  /// Get the subview of a certain type.
  func subview<T : UIView>(of type : T.Type, deepSearch: Bool = false) -> T? {

    if let found = subviews.first(where: { $0.isKind(of: type) }) as? T {
      return found
    }

    guard deepSearch else { return nil }

    for subview in subviews {

      if let found = subview.subview(of: type, deepSearch: true) {
        return found
      }

    }

    return nil

  }

  func subviews<T: UIView>(of type: T.Type) -> [T] {
    return subviews.filter { $0.isKind(of: type) } as? [T] ?? []
  }
  
}
