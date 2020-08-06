//
//  GifPlayerView+PanSeek.swift
//  Reddit
//
//  Created by made2k on 1/26/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AVKit

extension GifPlayerView {
  
  @objc func didPan(recognizer: UIPanGestureRecognizer) {
    guard let avPlayer = player, let item = avPlayer.currentItem else { return }
    guard item.duration.seconds > 1 else { return }
    guard Settings.allowGifScrolling else { return }
    
    switch recognizer.state {
    case .began:
      rateBeforeSeek = avPlayer.rate
      avPlayer.pause()
      previousSeekLocation = recognizer.location(in: nil).x
      
    case .changed:
      let offset = recognizer.location(in: nil).x - previousSeekLocation

      // If scrolling backwards, and not completed
      if offset < 0 && isSeekInProgress { return }

      previousSeekLocation = recognizer.location(in: nil).x
      
      // Get time scale to use
      let scaleConfig = CGFloat(item.duration.convertScale(1, method: CMTimeRoundingMethod.quickTime).value) * 1.1
      guard scaleConfig > 0 else { return }
      let timeScale: CMTimeScale = CMTimeScale(bounds.size.width / scaleConfig)
      
      // Get constraints
      let duration = CGFloat(item.duration.convertScale(timeScale, method: CMTimeRoundingMethod.quickTime).value)
      let currentTime = item.currentTime().convertScale(timeScale, method: CMTimeRoundingMethod.quickTime)
      
      // Get new CMTime to seek to
      let newTime = CMTimeValue((CGFloat(currentTime.value) + offset).clamped(to: 0...duration))
      stopPlayingAndSeekSmoothlyToTime(newChaseTime: CMTime(value: newTime, timescale: timeScale))
      
    case .ended, .cancelled:
      avPlayer.rate = rateBeforeSeek
      
    default:
      break
    }
  }
  
  // MARK: - Media Seek
  
  private func seekTo(time: CMTime) {
    player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
  }
  
  private func stopPlayingAndSeekSmoothlyToTime(newChaseTime:CMTime) {
    guard let player = player else { return }
    
    player.pause()
    
    if CMTimeCompare(newChaseTime, chaseTime) != 0 {
      
      chaseTime = newChaseTime;
      
      if !isSeekInProgress {
        trySeekToChaseTime()
      }
    }
  }
  
  private func trySeekToChaseTime() {
    guard let status = player?.currentItem?.status else { return }
    
    if status == .readyToPlay {
      actuallySeekToTime()
    }
  }
  
  private func actuallySeekToTime() {
    guard let player = player else { return }
    
    isSeekInProgress = true
    
    let seekTimeInProgress = chaseTime
    
    player.seek(
      to: seekTimeInProgress,
      toleranceBefore: CMTime.zero,
      toleranceAfter: CMTime.zero,
      completionHandler: { (isFinished:Bool) -> Void in
        
        if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
          self.isSeekInProgress = false
          
        }
          
        else {
          self.trySeekToChaseTime()
        }
    })
  }
}
