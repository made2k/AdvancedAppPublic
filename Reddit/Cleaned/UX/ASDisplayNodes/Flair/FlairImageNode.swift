//
//  FlairImageNode.swift
//  Reddit
//
//  Created by made2k on 7/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Logging
import PromiseKit

final class FlairImageNode: ASDisplayNode {
  
  private let imageNodes: [ASNetworkImageNode]
  private let insets: CGFloat = 2
  private let backupTintColor: UIColor
  
  init(urls: [URL], backgroundColor: UIColor?, backupTintColor: UIColor) {
    
    let imageNodes: [PromiseNetworkImageNode] = urls.map {
      let node = PromiseNetworkImageNode()
      node.url = $0
      node.contentMode = .scaleAspectFit
      node.style.flexShrink = 1
      return node
    }
    self.imageNodes = imageNodes
    self.backupTintColor = backupTintColor
    
    super.init()
    automaticallyManagesSubnodes = true
    self.backgroundColor = backgroundColor
    
    firstly {
      when(fulfilled: imageNodes.map { $0.imageDecodedPromise })
      
    }.done(on: .global(qos: .userInitiated)) { [weak self] in
      self?.imagesFinishedDownloading($0)
    
    }.catch {
      if case ApplicationError.objectDeallocated = $0 { return }
      log.error("failed to download flair image", error: $0)
    }
    
  }
  
  func setHeight(_ height: CGFloat) {
    style.height = ASDimension(unit: .points, value: height)
    imageNodes.forEach { $0.style.preferredSize = CGSize(square: height - (insets * 2)) }
  }
  
  private func imagesFinishedDownloading(_ images: [UIImage]) {
    // If the images we're dealing with vary in color, don't apply a tint.
    guard images.contains(where: { $0.isSingleColor == false }) == false else { return }

    let queue: DispatchQueue = isNodeLoaded ? .main : .global()
    queue.async {
      // If we've been given a background color, we don't need to tint.
      guard self.backgroundColor == nil else { return }
      self.imageNodes.forEach { $0.tintColor = self.backupTintColor }
    }
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let stack = ASStackLayoutSpec.horizontal()
    stack.children = imageNodes
    
    let inset = ASInsetLayoutSpec()
    inset.child = stack
    inset.insets = UIEdgeInsets(inset: insets)
    
    return inset
  }
  
}

private class PromiseNetworkImageNode: ASNetworkImageNode, ASNetworkImageNodeDelegate {

  let imageDecodedPromise: Promise<UIImage>
  private let imageDecodeResolver: Resolver<UIImage>
  
  init() {
    (imageDecodedPromise, imageDecodeResolver) = Promise<UIImage>.pending()
    super.init(cache: ASPINRemoteImageDownloader.shared(), downloader: ASPINRemoteImageDownloader.shared())
    delegate = self
  }

  deinit {
    if imageDecodedPromise.isPending {
      imageDecodeResolver.reject(ApplicationError.objectDeallocated)
    }
  }
  
  func imageNode(_ imageNode: ASNetworkImageNode, didFailWithError error: Error) {
    imageDecodeResolver.reject(error)
  }
  
  func imageNodeDidFinishDecoding(_ imageNode: ASNetworkImageNode) {
    
    guard let image = imageNode.image else {
      imageDecodeResolver.reject(GenericError.error)
      return
    }
    
    imageDecodeResolver.fulfill(image)
  }
  
}
