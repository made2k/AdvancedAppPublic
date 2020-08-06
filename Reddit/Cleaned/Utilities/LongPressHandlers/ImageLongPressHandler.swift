//
//  ImageLongPressHandler.swift
//  Reddit
//
//  Created by made2k on 1/28/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Photos.PHPhotoLibrary
import PromiseKit
import UIKit

struct ImageLongPressHandler {
  
  static func handleLongPress(_ image: UIImage, url: URL?, gesture: UILongPressGestureRecognizer) {
    
    let alert = AlertController()

    let share = shareAction(image: image, location: gesture.location(in: nil))
    alert.addAction(share)

    if let url = url {
      let openInWeb = openInWebAction(url: url)
      alert.addAction(openInWeb)
    }

    let saveToLibrary = saveToLibraryAction(image: image)
    alert.addAction(saveToLibrary)

    alert.show()
  }

  // MARK: - Action Creation

  private static func saveToLibraryAction(image: UIImage) -> AlertAction {

    let action = AlertAction(
      title: R.string.longPressHandlers.saveToLibraryAction(),
      icon: R.image.icon_photoLibrary()) {
        saveImageToPhotoLibrary(image)
    }

    return action
  }


  private static func openInWebAction(url: URL) -> AlertAction {

    return AlertAction(
      title: R.string.longPressHandlers.openInWebAction(),
      icon: R.image.icon_web()) {
        OpenInPreference.shared.openBrowser(url: url)
    }

  }

  private static func shareAction(image: UIImage, location: CGPoint) -> AlertAction {

    let action = AlertAction(
      title: R.string.longPressHandlers.shareAction(),
      icon: R.image.icon_action()) {

        let sourceView = SplitCoordinator.current.splitViewController.view

        // FIXME: This doesn't position properly on iOS 13 beta... maybe just beta issue
        let shareSheet = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        shareSheet.popoverPresentationController?.sourceView = sourceView
        shareSheet.popoverPresentationController?.sourceRect = CGRect(x: location.x, y: location.y, width: 0, height: 0)

        SplitCoordinator.current.topViewController.present(shareSheet)
    }

    return action

  }

  // MARK: - Helpers

  private static func saveImageToPhotoLibrary(_ image: UIImage) {

    firstly {
      PHPhotoLibrary.requestAuthorization()

      }.then { status -> Promise<Void> in
        guard status == .authorized else {
          throw PhotoLibraryError.notAuthorized
        }
        return PHPhotoLibrary.shared().saveImageToLibrary(image)

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
