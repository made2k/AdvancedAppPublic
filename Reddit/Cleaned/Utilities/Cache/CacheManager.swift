//
//  CacheManager.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Foundation
import Logging
import PINRemoteImage

class CacheManager: NSObject {

  static let shared = CacheManager()

  let videoCache = VideoCache.shared
  let imageCache: PINCache

  private override init() {

    let defaultTime = 14.days

    let imageCacheLimit = UInt(Settings.maxImageCacheSize.value)
    imageCache = ASPINRemoteImageDownloader.shared().sharedPINRemoteImageManager().cache as! PINCache
    imageCache.diskCache.byteLimit = imageCacheLimit
    imageCache.diskCache.ageLimit = defaultTime

    videoCache.byteLimit = UInt(Settings.maxGifCacheSize.value)
    videoCache.ageLimit = defaultTime

    super.init()
  }

  func configure() { }

}
