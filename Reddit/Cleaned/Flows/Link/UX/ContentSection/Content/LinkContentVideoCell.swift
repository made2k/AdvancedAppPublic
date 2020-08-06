//
//  VideoLinkCell.swift
//  Reddit
//
//  Created by made2k on 10/28/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AVKit
import AsyncDisplayKit
import MediaPlayer
import PromiseKit
import RedditAPI
import RxAVFoundation
import RxSwift
import Then

class LinkContentVideoCell: ASCellNode {
  
  private let videoContainerNode = ASDisplayNode()
  private let loadingIndicator = UIActivityIndicatorView(style: .large)
  private lazy var playerViewController: AVPlayerViewController = {
    let controller = AVPlayerViewController()
    controller.allowsPictureInPicturePlayback = false
    return controller
  }()

  private lazy var playerVolumeView: MPVolumeView = {
    let view = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    view.showsRouteButton = false
    view.showsVolumeSlider = true
    view.setRouteButtonImage(UIImage(), for: .normal)
    view.setVolumeThumbImage(UIImage(), for: .normal)
    return view
  }()

  private var onPlayerError: () -> Void
  private var disposeBag = DisposeBag()
  
  // MARK: - Initialization
  
  init(link: Link, onError: @escaping () -> Void) {
    self.onPlayerError = onError
    
    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    backgroundColor = .black

    if let url = link.media?.hlsUrl {
      loadWhenReady(url)

    } else {
      fetchVideo(link: link)
    }
    
  }

  override func didLoad() {
    super.didLoad()

    if playerViewController.player?.currentItem == nil {
      showLoadingIndicator()
    }

  }
  
  private func setupBindings(player: AVPlayer) {
    
    disposeBag = DisposeBag()
    
    player.rx.rate
      .filter { $0 > 0 }
      .subscribe(onNext: { [unowned self] _ in
        self.addVolumeView()
        self.playAudioOverSystemSounds()
      }).disposed(by: disposeBag)

    player.rx.rate
      .filter { $0 == 0 }
      .subscribe(onNext: { [unowned self] _ in
        self.allowSystemSounds()
        self.removeVolumeView()
      }).disposed(by: disposeBag)

    if let currentItem = player.currentItem {

      let isLoading: Observable<Bool> = currentItem.rx.status
        .map { (status: AVPlayerItem.Status) -> Bool in
          return status == AVPlayerItem.Status.unknown

        }.distinctUntilChanged()

      isLoading
        .map { (loading: Bool) -> CGFloat in
          return loading ? 0 : 1
        }
        .bind(to: playerViewController.view.rx.alpha)
        .disposed(by: disposeBag)

      isLoading
        .subscribe(onNext: { [unowned self] (loading: Bool) in

          if loading {
            self.showLoadingIndicator()

          } else {
            self.removeLoadingIndicator()
          }

        }).disposed(by: disposeBag)

      currentItem.rx.status
        .filter { $0 == .failed }
        .take(1)
        .subscribe(onNext: { [unowned self] _ in
          self.onPlayerError()
        }).disposed(by: disposeBag)

      currentItem.rx.status
        .filter { $0 == AVPlayerItem.Status.readyToPlay }
        .filter { _ in Settings.autoPlayVideos }
        .take(1)
        .subscribe(onNext: { _ in
          player.play()
        }).disposed(by: disposeBag)

    }
  }
  
  // MARK: - Lifecycle

  override func layoutDidFinish() {
    super.layoutDidFinish()
    playerViewController.view.frame = bounds
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let ratio = ASRatioLayoutSpec(ratio: 9/16, child: videoContainerNode)
    return ratio
  }
  
  // MARK: - Video Loading and Playing

  private func fetchVideo(link: Link) {

    firstly {
      VideoExtractor.extractVideoUrl(link: link)

    }.done {
      self.loadWhenReady($0)

    }.catch { _ in
      self.onPlayerError()
    }

  }

  private func loadWhenReady(_ url: URL) {
    
    videoContainerNode.onDidLoad { [weak self] _ in
      self?.loadVideo(url: url)
    }
    
  }
  
  private func loadVideo(url: URL) {

    let avPlayer = AVPlayer(url: url)
    avPlayer.isMuted = Settings.autoMuteVideos.value
    setupBindings(player: avPlayer)
    
    playerViewController.view.frame = videoContainerNode.view.bounds
    playerViewController.player = avPlayer
    videoContainerNode.view.addSubview(playerViewController.view)
    
    if let time = url.videoTimeStamp() {
      let cmTime = CMTimeMakeWithSeconds(time, preferredTimescale: 1)
      avPlayer.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
  }

  // MARK: - Helpers

  private func showLoadingIndicator() {
    guard loadingIndicator.superview == nil else { return }

    view.addSubview(loadingIndicator)
    loadingIndicator.startAnimating()

    loadingIndicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }

  }

  private func removeLoadingIndicator() {
    loadingIndicator.stopAnimating()
    loadingIndicator.removeFromSuperview()
  }

  private func playAudioOverSystemSounds() {
    try? AVAudioSession.sharedInstance().setCategory(.playback,
                                                     mode: .default,
                                                     options: .init(rawValue: 0))
  }

  private func allowSystemSounds() {
    try? AVAudioSession.sharedInstance().setCategory(.playback,
                                                     mode: .default,
                                                     options: .mixWithOthers)
  }

  private func addVolumeView() {
    guard playerVolumeView.superview == nil else { return }
    playerViewController.view.addSubview(playerVolumeView)
  }

  private func removeVolumeView() {
    playerVolumeView.removeFromSuperview()
  }
  
}

extension LinkContentVideoCell: VideoDisposable {
  
  func disposeVideo() {
    playerViewController.player?.pause()
    disposeBag = DisposeBag()
  }
  
}
