//
//  UniversalMediaNode+Video.swift
//  Reddit
//
//  Created by made2k on 2/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Alamofire
import AsyncDisplayKit
import Foundation
import PromiseKit
import RxSwift

extension UniversalMediaNode {
  
  private struct AssociatedKeys {
    static var networkDisposeBag: UInt8 = 0
    static var gifVideoView: UInt8 = 1
    static var shouldBePlaying: UInt8 = 2
  }
  
  // Used to observe reachability status change
  private var networkDisposeBag: DisposeBag? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.networkDisposeBag) as? DisposeBag
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.networkDisposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private var gifPlayer: GifVideoNode? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.gifVideoView) as? GifVideoNode
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.gifVideoView, newValue, .OBJC_ASSOCIATION_ASSIGN)
    }
  }
  
  // Determine an intermediate state of playing
  // potentially before the gif player becomes available
  private var shouldBePlaying: Bool {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.shouldBePlaying) as? Bool ?? false
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.shouldBePlaying, newValue, .OBJC_ASSOCIATION_ASSIGN)
    }
  }
  
  func playVideo(_ url: URL) {
    
    if shouldAutoDownloadAndPlayGif(for: url) {
      downloadVideo(url)
      
    } else {
      showTapToPlay(url)
    }
    
  }
  
  private func downloadVideo(_ url: URL) {
    guard videoDownloadUrl == nil else { return }

    clearState()
    removeNetworkObserver()

    videoDownloadUrl = url

    let progressBlock: Request.ProgressHandler = { [weak self] requestProgress in
      self?.updateProgress(progress: requestProgress.fractionCompleted, totalBytes: requestProgress.totalUnitCount)
    }

    firstly {
      VideoDownloader.shared.getVideo(url: url, progress: progressBlock)

    }.done {
      self.videoDownloadComplete(asset: $0)

    }.catch { error in
      self.videoDownloadFailed(error)
    }

  }
  
  private func videoDownloadComplete(asset: AVAsset) {
    isLoading = false
    videoDownloadUrl = nil
    
    let gifPlayerNode = GifVideoNode(asset: asset)
    gifPlayerNode.shouldAutoplay = shouldAutoPlay
    weak var weakPlayer = gifPlayerNode
    let container = GifVideoContainerNode(videoNode: gifPlayerNode)
    
    gifPlayerNode.tapAction = { [unowned self] in
      let time = weakPlayer?.player?.currentTime()
      self.onVideoTapped(asset, at: time)
    }
    // Store a weak reference to this for easy access
    self.gifPlayer = gifPlayerNode
    
    if shouldBePlaying {
      gifPlayerNode.play()
    } else {
      gifPlayerNode.pause()
    }
    
    setContentNode(node: container)
  }
  
  @objc func videoDownloadFailed(_ error: Error) {
    isLoading = false
    videoDownloadUrl = nil
  }
  
  private func onVideoTapped(_ asset: AVAsset, at time: CMTime?) {
    guard let presentingController = closestViewController else { return }

    let mediaController = OverviewMediaViewController(asset: asset, link: linkModel, time: time)
    presentingController.present(mediaController)
  }

}

// MARK: - Autoplay handling

extension UniversalMediaNode {
  
  private func showTapToPlay(_ url: URL) {
    setText("Autoplay is disabled for GIFs. Tap here to download and play.")

    tapAction = { [unowned self] in
      self.downloadVideo(url)
      self.tapAction =  nil
    }
    
    setupNetworkObserver(url)
  }
  
  private func setupNetworkObserver(_ url: URL) {
    
    networkDisposeBag = nil
    
    guard Settings.autoPlayGifsOnCellular == false else { return }
    guard Reachability.shared.isReachableOnWiFi == false else { return }
    
    let disposeBag = DisposeBag()
    networkDisposeBag = disposeBag
    
    Reachability.shared.rx.reachableOnWifi
      .filter { $0 }
      .take(1)
      .subscribe(onNext: { [unowned self] _ in
        self.downloadVideo(url)
      }).disposed(by: disposeBag)
    
  }
  
  private func removeNetworkObserver() {
    networkDisposeBag = nil
  }
  
}

// MARK: - MediaActions

extension UniversalMediaNode {

  func play() {
    shouldBePlaying = true
    gifPlayer?.play()
  }

  func pause() {
    shouldBePlaying = false
    gifPlayer?.pause()
  }

}
