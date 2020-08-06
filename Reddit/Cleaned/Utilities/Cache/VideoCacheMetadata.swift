//
//  VideoCacheMetadata.swift
//  Reddit
//
//  Created by made2k on 2/10/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

class VideoCacheMetaData: NSObject {
  var date: Date
  var size: Int

  override init() {
    date = Date.distantPast
    size = 0
  }
}
