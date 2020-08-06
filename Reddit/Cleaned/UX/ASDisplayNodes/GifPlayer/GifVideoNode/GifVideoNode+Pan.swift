//
//  GifVideoNode+Pan.swift
//  Reddit
//
//  Created by made2k on 2/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import CoreMedia
import UIKit

extension GifVideoNode {
  
  private struct AssociatedKeys {
    static var rateBeforeSeek: UInt8 = 0
    static var previousSeekLocation: UInt8 = 1
  }
  
  private var rateBeforeSeek: Float {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.rateBeforeSeek) as? Float ?? 0
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.rateBeforeSeek, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  private var previousSeekLocation: CGFloat {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.previousSeekLocation) as? CGFloat ?? 0
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.previousSeekLocation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  
  func didPan(recognizer: UIPanGestureRecognizer) {
    guard let player = player, let item = player.currentItem else { return }
    guard item.duration.seconds > 1 else { return }
    guard Settings.allowGifScrolling else { return }

    switch recognizer.state {
    case .began:
      rateBeforeSeek = player.rate
      player.pause()
      previousSeekLocation = recognizer.location(in: nil).x
      
    case .changed:
      let offset = recognizer.location(in: nil).x - previousSeekLocation

      // Fix slow scrolling backwards for certain encoded videos
      if offset < 0 && player.isSeekInProgress { return }

      previousSeekLocation = recognizer.location(in: nil).x
      
      // Get time scale to use
      let scaleConfig = CGFloat(item.duration.convertScale(1, method: CMTimeRoundingMethod.quickTime).value) * 1.1
      guard scaleConfig > 0 else { return }
      let timeScale: CMTimeScale = CMTimeScale(bounds.size.width / scaleConfig)
      
      // Get constraints
      let duration = CGFloat(item.duration.convertScale(timeScale, method: CMTimeRoundingMethod.quickTime).value)
      let currentTime = item.currentTime().convertScale(timeScale, method: CMTimeRoundingMethod.quickTime)
      
      // Get new CMTime to seek to
      let newTimeValue = CMTimeValue((CGFloat(currentTime.value) + offset).clamped(to: 0...duration))
      let newTime = CMTime(value: newTimeValue, timescale: timeScale)
      player.seekSmoothly(to: newTime)
      
    case .ended, .cancelled:
      player.rate = rateBeforeSeek
      
    default:
      break
    }
  }
  
}
