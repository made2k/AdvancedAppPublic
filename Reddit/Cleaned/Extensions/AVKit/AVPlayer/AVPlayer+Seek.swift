//
//  AVPlayer+Seek.swift
//  Reddit
//
//  Created by made2k on 2/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AVKit
import CoreMedia

extension AVPlayer {
  
  private struct AssociatedKeys {
    static var chaseTime: UInt8 = 0
    static var isSeekInProgress: UInt8 = 1
  }
  
  private var chaseTime: CMTime {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.chaseTime) as? CMTime ?? .zero
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.chaseTime, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  private(set) var isSeekInProgress: Bool {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.isSeekInProgress) as? Bool ?? false
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.isSeekInProgress, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  
  func seekSmoothly(to time: CMTime) {
    guard currentItem?.status == .readyToPlay else { return }
    
    stopPlayingAndSeekSmoothlyToTime(newChaseTime: time)
  }
  
  private func stopPlayingAndSeekSmoothlyToTime(newChaseTime: CMTime) {
    pause()
    
    if CMTimeCompare(newChaseTime, chaseTime) != 0 {
      
      chaseTime = newChaseTime;
      
      if !isSeekInProgress {
        seekToTime()
      }
      
    }
  }
  
  private func seekToTime() {
    
    isSeekInProgress = true
    
    let seekTimeInProgress = chaseTime
    
    seek(
      to: seekTimeInProgress,
      toleranceBefore: CMTime.zero,
      toleranceAfter: CMTime.zero,
      completionHandler: { (isFinished: Bool) -> Void in
        
        if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
          self.isSeekInProgress = false
          
        }
          
        else {
          self.seekToTime()
        }
        
    })
  }

}
