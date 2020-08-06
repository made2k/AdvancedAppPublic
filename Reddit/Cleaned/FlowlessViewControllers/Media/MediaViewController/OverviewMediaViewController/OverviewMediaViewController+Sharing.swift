//
//  OverviewMediaViewController+Sharing.swift
//  Reddit
//
//  Created by made2k on 8/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AVKit
import UIKit

extension OverviewMediaViewController {

  func showShareOptions(from view: UIView?) {

    let alert = AlertController()

    if let url = linkModel?.link.url, let image = mediaView.imageView?.image {
      showImageShareOptions(alert, view: view, url: url, image: image)

    } else if let url = linkModel?.link.url, let video = mediaView.gifView?.asset as? AVURLAsset {
      showGifShareOptions(alert, view: view, url: url, videoAsset: video)

    } else if let url = linkModel?.link.url {
      showShareSheet(items: [url], from: view)
    }
    
  }

  private func showImageShareOptions(_ alert: AlertController, view: UIView?, url: URL, image: UIImage) {
    let linkAction = AlertAction(title: "Image Link", icon: nil) { [unowned self] in
      self.showShareSheet(items: [url], from: view)
    }
    alert.addAction(linkAction)

    let dataAction = AlertAction(title: "Image Data", icon: nil) { [unowned self] in
      self.showShareSheet(items: [image], from: view)
    }
    alert.addAction(dataAction)

    alert.show()
  }

  private func showGifShareOptions(_ alert: AlertController, view: UIView?, url: URL, videoAsset:AVURLAsset) {
    let linkAction = AlertAction(title: "GIF Link", icon: nil) { [unowned self] in
      self.showShareSheet(items: [url], from: view)
    }
    alert.addAction(linkAction)

    let dataAction = AlertAction(title: "GIF Data", icon: nil) { [unowned self] in
      let dataUrl = videoAsset.url
      self.showShareSheet(items: [dataUrl], from: view)
    }
    alert.addAction(dataAction)

    alert.show()
  }

  func showShareSheet(items: [Any], from sourceView: UIView?) {
    guard items.isEmpty == false else { return }

    let share = UIActivityViewController(activityItems: items, applicationActivities: nil)
    share.popoverPresentationController?.sourceRect = sourceView?.frame ?? CGRect(x: view.frame.size.width / 2, y: view.frame.size.height / 2, width: 0, height: 0)
    share.popoverPresentationController?.sourceView = view

    present(share)
  }

}
