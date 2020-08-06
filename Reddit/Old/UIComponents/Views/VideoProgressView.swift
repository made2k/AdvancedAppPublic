//
//  VideoProgressView.swift
//  Reddit
//
//  Created by made2k on 1/23/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AVKit
import DACircularProgress

class VideoProgressView: DACircularProgressView {
  var refreshRate: CGFloat = 1/8
  
  private let minValue: CGFloat = 0
  private let maxValue: CGFloat = 1
  
  private var dimmedKey = "com.advancedapp.reddit.videoprogressview.dimmedkey"
  private let dimmedValue: CGFloat = 0.25
  
  private var item: AVPlayerItem?
  
  init() {
    super.init(frame: .zero)
    commonInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func commonInit() {
    trackTintColor = .clear
    progressTintColor = .white
    roundedCorners = 1
    
    if UserDefaults.standard.bool(forKey: dimmedKey) {
      alpha = dimmedValue
    }
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(wasTapped))
    addGestureRecognizer(tap)
  }
  
  func attach(_ videoPlayer: AVPlayer) {
    let timeScaleValue: CMTimeValue = 1
    let timeScale: CMTimeScale = Int32(1 / refreshRate)
    let interval = CMTime(value: timeScaleValue, timescale: timeScale)
    
    item = videoPlayer.currentItem

    videoPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] time in
      self?.observeTimeChange(time)
    })
  }
  
  @objc private func wasTapped() {
    if alpha == 1 {
      alpha = dimmedValue
      UserDefaults.standard.set(true, forKey: dimmedKey)
    } else {
      alpha = 1
      UserDefaults.standard.set(false, forKey: dimmedKey)
    }
  }
  
  private func observeTimeChange(_ time: CMTime) {
    guard let item = item else { return }

    let playerDuration = item.duration
    if CMTIME_IS_INVALID(playerDuration) {
      progress = 0
      return
    }
    let duration = CGFloat(CMTimeGetSeconds(playerDuration))
    if duration.isFinite && duration > 0 {
      let time = CGFloat(CMTimeGetSeconds(item.currentTime()))

      let value = (maxValue - minValue) * time / duration + minValue
      progress = value
    }
  }
}
