//
//  ThumbnailNode.swift
//  Reddit
//
//  Created by made2k on 4/11/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import SafariServices
import RxSwift

class ThumbnailNode: ASNetworkImageNode {

  private let model: LinkModel
  private let contextMenu: ContextMenu?

  private let disposeBag = DisposeBag()
  
  init(linkModel: LinkModel) {
    self.model = linkModel

    if let url = linkModel.link.url {
      let expectedSize = linkModel.link.preview?.sourceSize
      /*
       We have a URL, if this url is an unsupported gif, we need to instead
       use the media provided by reddit.
       */
      if url.isUnsupportedRedditGif(), let preview = linkModel.link.preview?.mp4?.source.url {
        self.contextMenu = UrlPreviewContextMenu(url: preview, mediaSize: expectedSize)
        
      } else {
        self.contextMenu = UrlPreviewContextMenu(url: url, mediaSize: expectedSize)
      }

    } else {
      self.contextMenu = nil
    }

    let downloader = ASPINRemoteImageDownloader.shared()
    super.init(cache: downloader, downloader: downloader)

    contentMode = .scaleAspectFill
    clipsToBounds = true
    style.preferredSize = CGSize(square: Settings.thumbnailSize.value)
    cornerRadius = 5

    url = linkModel.thumbnail

    setupBindings()
  }

  override func didLoad() {
    super.didLoad()
    view.accessibilityIgnoresInvertColors = true
    
    contextMenu?.register(view: self.view)
  }

  private func setupBindings() {

    Settings.thumbnailSize
      .map { CGSize(square: $0) }
      .bind(to: rx.preferredSize, setNeedsLayout: self)
      .disposed(by: disposeBag)
  }

}
