//
//  GifPlayerView.swift
//  Reddit
//
//  Created by made2k on 1/2/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AVKit

import Alamofire
import PromiseKit
import DACircularProgress
import Logging

protocol GifPlayerViewDelegate {
  func videoSizeDidChange(_ size: CGSize?)
}

typealias DownloadProgressBlock = (Double, Int64?) -> Void

//TODO: Move to module so file extensions have internal access
class GifPlayerView: UIView {
  override var frame: CGRect {
    didSet {
      playerLayer?.frame = frame
      playerLayer?.removeAllAnimations()
    }
  }
  
  override var bounds: CGRect {
    didSet {
      playerLayer?.frame = bounds
      playerLayer?.removeAllAnimations()
    }
  }

  // MARK: Video player
  
  internal var player: AVPlayer?
  fileprivate var playerLayer: AVPlayerLayer?
  private(set) var asset: AVAsset?
  var currentTime: CMTime? {
    return player?.currentTime()
  }
  var videoSize: CGSize? {
    return playerLayer?.videoRect.size
  }
  
  // MARK: Downloading
  
  private var videoDownloadUrl: URL?
  private var fetchCache: Promise<AVAsset>?
  internal var url: URL?
  
  // MARK: Seeking
  
  internal var rateBeforeSeek: Float = 1
  private(set) var panGesture: UIPanGestureRecognizer?
  internal var previousSeekLocation: CGFloat = 0
  internal var chaseTime = CMTime.zero
  internal var isSeekInProgress = false
  
  weak var pinchToZoomGesture: UIGestureRecognizer?
  
  // MARK: - View Helpers
  
  fileprivate var longPressGesture: UILongPressGestureRecognizer?
  private lazy var progressHud: VideoProgressView = {
    return VideoProgressView()
  }()
  
  private let volumeContainer: UIStackView?
  
  init(volumeView: UIStackView?) {
    self.volumeContainer = volumeView
    super.init(frame: .zero)

    self.accessibilityIgnoresInvertColors = true
    setupVideoGestures()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Observers
  
  private let delegates: SwiftMulticastDelegate<GifPlayerViewDelegate> = SwiftMulticastDelegate()
  
  func addDelegate(_ delegate: GifPlayerViewDelegate) {
    delegates.addDelegate(delegate)
  }
  
  override func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)
    if newWindow == nil {
      player?.pause()
    } else {
      player?.play()
    }
  }
  
  // MARK: - Play video

  func playVideo(_ url: URL, progress: DownloadProgressBlock?, completion: ((Error?) -> Void)?) {
    self.url = url

    firstly {
      fetchVideo(url: url, progress: progress)

    }.done { [weak self] asset in
      guard let _self = self else { return }
      _self.playVideo(asset)
      completion?(nil)

    }.catch { error in
      completion?(error)
    }
  }
  
  func playVideo(_ asset: AVAsset, at time: CMTime? = .zero) {
    mixAudio()

    self.asset = asset

    let item = AVPlayerItem(asset: asset)

    let videoPlayer = LoopablePlayer(playerItem: item)
    videoPlayer.isMuted = true
    videoPlayer.allowsExternalPlayback = false

    let playerLayer = AVPlayerLayer(player: videoPlayer)
    playerLayer.frame = self.frame
    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
    playerLayer.needsDisplayOnBoundsChange = true

    playerLayer.addObserver(self, forKeyPath: "videoRect", options: NSKeyValueObservingOptions.new, context: nil)

    self.player = videoPlayer
    self.playerLayer = playerLayer

    self.layer.addSublayer(playerLayer)

    if !Settings.hideGifProgress {
      addSubview(progressHud)

      progressHud.snp.makeConstraints { make in
        make.top.equalTo(safeAreaLayoutGuide.snp.topMargin).offset(20)
        make.left.equalTo(safeAreaLayoutGuide.snp.leftMargin).offset(20)
        make.height.equalTo(self.progressHud.snp.width)
        make.width.equalTo(15)
      }

      progressHud.attach(videoPlayer)
    }

    if !asset.tracks(withMediaType: .audio).isEmpty {
      // show volume indicator
      showVolumeButton()
    }

    videoPlayer.seek(
      to: time ?? .zero,
      toleranceBefore: .zero,
      toleranceAfter: .zero
    ) { [unowned self] _ in

      if self.shouldBePlaying {
        videoPlayer.play()
      }

    }

  }
  
  private func showVolumeButton() {
    let isMuted = player?.isMuted == true
    
    let button = UIButton(frame: .zero)
    let image = isMuted ? R.image.icon_volume_off() : R.image.icon_volume_on()
    button.setImage(image, for: .normal)
    button.tintColor = .white
    button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    button.layer.cornerRadius = 5
    button.addTarget(self, action: #selector(toggleMute), for: .touchUpInside)
    
    volumeContainer?.addArrangedSubview(button)
  }
  
  @objc private func toggleMute(sender: UIButton) {
    guard let player = player else { return }
    let newValue = !player.isMuted
    player.isMuted = newValue
    let image = newValue ? R.image.icon_volume_off() : R.image.icon_volume_on()
    sender.setImage(image, for: .normal)
  }
  
  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    
    if let layer = object as? AVPlayerLayer, keyPath == "videoRect" {
      delegates.invokeDelegates({ $0.videoSizeDidChange(layer.videoRect.size) })
    }
  }
  
  // MARK: - Autoplay Options

  func showTapToPlay() {
    
  }
  
  // MARK: - AVPlayer passthrough

  private var shouldBePlaying: Bool = true
  
  func pause() {
    shouldBePlaying = false
    player?.pause()
  }
  
  func resume() {
    shouldBePlaying = true
    if 1.0 != player?.rate {
      player?.play()
    }
  }
  
  // MARK: - Video Fetching
  
  private func fetchVideo(url: URL, progress: DownloadProgressBlock? = nil) -> Promise<AVAsset> {
    if let asset = asset { return .value(asset) }

    VideoDownloader.shared.cancelDownload(for: url)

    let progressBlock: Request.ProgressHandler = { request in
      progress?(request.fractionCompleted, Int64(request.fileTotalCount ?? 1))
    }

    return VideoDownloader.shared.getVideo(url: url, progress: progressBlock)
  }
  
  // MARK: - Disposing due to max layers

  // TODO: When gif in preview, and dismisses, memory keeps increasing
  func removePlayer() {
    if let layer = playerLayer, layer.superlayer != nil {
      layer.removeObserver(self, forKeyPath: "videoRect")
      layer.removeFromSuperlayer()
    }
    
    playerLayer = nil
    player = nil
  }
  
  func addPlayer() {
    if let asset = asset, playerLayer == nil {
      playVideo(asset)
    }
  }
  
  // MARK: - Helpers
  
  private func mixAudio() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
    } catch {
      log.error("failed to set audio session playback to .mixWithOthers", error: error)
    }
  }

  func dispose() {
    if let downloadUrl = videoDownloadUrl {
      VideoDownloader.shared.cancelDownload(for: downloadUrl)
    }
  }
  
  deinit {
    dispose()
    playerLayer?.removeObserver(self, forKeyPath: "videoRect")
  }
}

// MARK: - Gesture Scrobbling

extension GifPlayerView: UIGestureRecognizerDelegate {
  
  fileprivate func setupVideoGestures() {
    
    if longPressGesture == nil {
      let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(gesture:)))
      addGestureRecognizer(gesture)
    }
    
    if panGesture == nil {
      let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(recognizer:)))
      gesture.maximumNumberOfTouches = 1
      panGesture = gesture
      gesture.delegate = self
      addGestureRecognizer(gesture)
    }
  }
  
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard gestureRecognizer === panGesture else { return true }
    guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
    
    guard gesture.location(in: self).x > 50 else { return false }

    let translation = gesture.translation(in: nil)
    return abs(translation.x) > abs(translation.y) + 0.25
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return Settings.allowGifScrolling
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }

}
