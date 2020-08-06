//
//  GifLongPressHandler.swift
//  Reddit
//
//  Created by made2k on 6/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AVFoundation
import AVKit
import Photos.PHPhotoLibrary
import PromiseKit
import UIKit

struct GifLongPressHandler {

  // TODO: Should make sure urls ever get set
  static func handleLongPress(player: AVPlayer, item: AVPlayerItem, webUrl: URL?, fileUrl: URL?, gesture: UILongPressGestureRecognizer) {

    let alert = AlertController()

    if let videoAsset = (item.asset as? AVURLAsset) {
      let share = shareAction(asset: videoAsset, location: gesture.location(in: nil))
      alert.addAction(share)
    }

    if let url = webUrl {
      let openInWeb = openInBrowserAction(url)
      alert.addAction(openInWeb)
    }

    let videoPlayer = openInVideoPlayerAction(item)
    alert.addAction(videoPlayer)

    if let url = fileUrl {
      let saveToLibrary = saveToLibraryAction(url)
      alert.addAction(saveToLibrary)
    }

    let playbackSpeed = playbackSpeedAction(player)
    alert.addAction(playbackSpeed)

    alert.show()
  }

  // MARK: - Action Creation

  private static func shareAction(asset: AVURLAsset, location: CGPoint) -> AlertAction {

    let action = AlertAction(
      title: R.string.longPressHandlers.shareAction(),
      icon: R.image.icon_action()) {

        let sourceView = SplitCoordinator.current.splitViewController.view

        let shareSheet = UIActivityViewController(activityItems: [asset.url], applicationActivities: nil)
        shareSheet.popoverPresentationController?.sourceView = sourceView
        shareSheet.popoverPresentationController?.sourceRect = CGRect(x: location.x, y: location.y, width: 0, height: 0)

        SplitCoordinator.current.topViewController.present(shareSheet)
    }

    return action
  }

  private static func openInBrowserAction(_ url: URL) -> AlertAction {
    return AlertAction(
      title: R.string.longPressHandlers.openInWebAction(),
      icon: R.image.icon_web()) {
        OpenInPreference.shared.openBrowser(url: url)
    }
  }

  private static func openInVideoPlayerAction(_ currentItem: AVPlayerItem) -> AlertAction {
    let action = AlertAction(
      title: R.string.longPressHandlers.openInVideoPlayer(),
      icon: R.image.icon_videoPlayer()) {

        let item = AVPlayerItem(asset: currentItem.asset)
        let copy = LoopablePlayer(playerItem: item)
        copy.seek(to: currentItem.currentTime(), completionHandler: {_ in})

        let vc = AVPlayerViewController()
        vc.player = copy
        copy.play()

        SplitCoordinator.current.topViewController.present(vc)
    }

    return action
  }

  private static func saveToLibraryAction(_ url: URL) -> AlertAction {

    return AlertAction(
      title: R.string.longPressHandlers.saveToLibraryAction(),
      icon: R.image.icon_photoLibrary()) {
        saveVideoFileToPhotoLibrary(url)
    }

  }

  private static func playbackSpeedAction(_ player: AVPlayer) -> AlertAction {

    let action = AlertAction(
      title: R.string.longPressHandlers.changePlaybackSpeedAction(),
      icon: R.image.iconMediaForward(),
      hasNext: true) {
        showPlaybackSpeedOptions(with: player)
    }

    return action
  }

  private static func showPlaybackSpeedOptions(with player: AVPlayer) {

    let alert = AlertController()

    let options: [(String, Float, UIImage?)] = [
      ("-2", -2, R.image.iconMediaReverse()),
      ("-1.5", -1.5, R.image.iconMediaReverse()),
      ("-1", -1, R.image.iconMediaReverse()),
      ("-0.5", -0.5, R.image.iconMediaReverse()),
      ("0", 0, R.image.iconMediaPause()),
      ("0.5", 0.5, R.image.iconMediaPlay()),
      ("1", 1, R.image.iconMediaPlay()),
      ("1.5", 1.5, R.image.iconMediaForward()),
      ("2", 2, R.image.iconMediaForward())
    ]

    for option in options {

      let action = AlertAction(title: option.0, icon: option.2) {
        player.rate = option.1
      }
      alert.addAction(action)
      
    }

    alert.show()
  }

  // MARK: - Helpers

  private static func saveVideoFileToPhotoLibrary(_ fileUrl: URL) {

    firstly {
      PHPhotoLibrary.requestAuthorization()

    }.then { status -> Promise<Void> in
      guard status == .authorized else {
        throw PhotoLibraryError.notAuthorized
      }
      return PHPhotoLibrary.shared().saveFileToLibrary(fileUrl)

    }.done {
      Overlay.shared.flashSuccessOverlay(R.string.longPressHandlers.saveToLibrarySuccess())

    }.catch { error in
      if case PhotoLibraryError.notAuthorized = error {
        SplitCoordinator.current.splitViewController.handleNoPhotoAccess()

      } else {
        Overlay.shared.flashErrorOverlay(R.string.longPressHandlers.saveToLibraryFailure())
      }
    }

  }

}
