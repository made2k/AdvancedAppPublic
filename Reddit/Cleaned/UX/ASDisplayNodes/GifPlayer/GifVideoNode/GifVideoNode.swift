//
//  GifVideoNode.swift
//  Reddit
//
//  Created by made2k on 2/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxCocoa
import RxSwift

final class GifVideoNode: ASVideoNode {
  
  override weak var delegate: ASVideoNodeDelegate? {
    get { return self }
    set {
      guard self === newValue else { return }
      super.delegate = newValue
    }
  }

  private var latestPlayRate: Float = 0
  private let videoProgressRelay = BehaviorRelay<Double>(value: 0)
  /**
   Allows observer to watch the progress of the video. This
   value will be between 0 and 1.
   */
  var videoProgressObserver: Observable<Double> {
    return videoProgressRelay.asObservable()
  }

  private let playerRelay = BehaviorRelay<AVPlayer?>(value: nil)
  lazy private(set) var playerObserver: Observable<AVPlayer?> = {
    return playerRelay.asObservable().share()
  }()

  init(asset: AVAsset) {
    let downloader = ASPINRemoteImageDownloader.shared()
    super.init(cache: downloader, downloader: downloader)
    
    automaticallyManagesSubnodes = true

    self.asset = asset
    self.muted = true
    self.delegate = self

    self.shouldAutoplay = true
    self.shouldAutorepeat = false
  }

  override func didLoad() {
    super.didLoad()

    let panGesture = UIPanGestureRecognizer { [weak self] in
      self?.didPan(recognizer: $0)
    }
    panGesture.delegate = self
    view.addGestureRecognizer(panGesture)

    view.onLongPress { [weak self] in
      self?.didLongPress(gesture: $0)
    }
  }

  override func didExitVisibleState() {
    super.didExitVisibleState()
    pause()
  }

  override func didExitPreloadState() {
    super.didExitPreloadState()
    playerRelay.accept(nil)
  }

}

extension GifVideoNode: ASVideoNodeDelegate {
  
  func didTap(_ videoNode: ASVideoNode) {
    // do nothing, this intercepts the auto play pause
  }

  func videoNode(_ videoNode: ASVideoNode, didPlayToTimeInterval timeInterval: TimeInterval) {

    guard let duration = videoNode.currentItem?.duration else { return }

    if let rate = videoNode.player?.rate, rate != 0 {
      latestPlayRate = rate
    }

    // If we're playing in reverse and we're at 0 duration
    if latestPlayRate < 0 && timeInterval.rounded(numberOfDecimalPlaces: 1, rule: .toNearestOrEven) == 0 {

      let targetTime = duration.seconds
      let tolerance: CMTime = CMTime(seconds: 0.1, preferredTimescale: duration.timescale)
      let target = CMTime(seconds: targetTime, preferredTimescale: duration.timescale)
      let resumeRate = self.latestPlayRate

      // The total duration must be greater than tolerance otherwise issues.
      guard duration.seconds > tolerance.seconds else {
        videoNode.pause()
        return
      }

      // Stop attempting to play any more while we seek
      videoNode.pause()

      videoNode.player?.seek(to: target, toleranceBefore: tolerance, toleranceAfter: tolerance) { finished in
        // the seek has to have finished before we start playing again
        guard finished else { return }
        videoNode.player?.rate = resumeRate
      }

    }

    guard duration.seconds > 0 else {
      videoProgressRelay.accept(0)
      return
    }

    let percent = timeInterval / duration.seconds
    videoProgressRelay.accept(percent)
  }

  func videoDidPlay(toEnd videoNode: ASVideoNode) {
    videoNode.player?.seek(to: .zero) { [weak self] _ in
      guard let self = self else { return }
      videoNode.player?.rate = self.latestPlayRate
    }
  }

  func videoNode(_ videoNode: ASVideoNode, didSetCurrentItem currentItem: AVPlayerItem) {
    playerRelay.accept(videoNode.player)
    videoNode.player?.allowSleepDuringPlayback()
  }

}
