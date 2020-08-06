//
//  UniversalMediaNode+Image.swift
//  Reddit
//
//  Created by made2k on 2/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import PINRemoteImage

extension UniversalMediaNode {

  func displayImage(_ url: URL) {

    guard imageDownloadId == nil else { return }
    
    let progressBlock: PINRemoteImageManagerProgressDownload = { [weak self] completed, total in
      let safeTotal: Int64 = max(total, 1)
      let percent = Double(completed) / Double(safeTotal)
      
      self?.updateProgress(progress: percent, totalBytes: total)
    }
    let completionBlock: PINRemoteImageManagerImageCompletion =  { [weak self] result in
      self?.handleImageCompletion(result: result, url: url)
    }

    imageDownloadId = imageDownloader
      .downloadImage(with: url,
                     options: [.downloadOptionsSkipDecode],
                     progressDownload: progressBlock,
                     completion: completionBlock)
    
  }
    
  private func handleImageCompletion(result: PINRemoteImageManagerResult, url: URL) {

    isLoading = false
    imageDownloadId = nil
    
    if result.error != nil { return loadMediaFailed() }
    guard let image = result.image else { return loadMediaFailed() }
    
    downloadProgress.accept(nil)
    
    let imageNode = ASImageNode()
    imageNode.contentMode = .scaleAspectFit
    imageNode.image = image
    imageNode.observeDimming()
    
    imageNode.tapAction = { [unowned self] in
      self.imageTapped(image: image)
    }
    
    imageNode.onDidLoad { node in
      node.view.accessibilityIgnoresInvertColors = true
      
      node.view.onLongPress { gesture in
        guard gesture.state == .began else { return }
        ImageLongPressHandler.handleLongPress(image, url: url, gesture: gesture)
      }
    }
    
    setMediaSize(image.size)
    setContentNode(node: imageNode)
  }
  
  // Subclasses can override to change the action.
  // by default, show media view controller
  @objc func imageTapped(image: UIImage) {
    guard let presentingController = closestViewController else { return }

    let mediaController = OverviewMediaViewController(image: image, linkModel: linkModel)
    presentingController.present(mediaController)
  }
  
}
