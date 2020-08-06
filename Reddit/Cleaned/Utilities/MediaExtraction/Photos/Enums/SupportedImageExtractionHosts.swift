//
//  SupportedImageExtractionHosts.swift
//  Reddit
//
//  Created by made2k on 6/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

enum SupportedImageExtractionHosts {

  case giphy
  case gfycat
  case imgur
  case reddit
  case redditPreview
  case redditVideo
  case redgifs

  static func match(url: URL) -> SupportedImageExtractionHosts? {

    let urlString = url.absoluteString.lowercased()
    
    if url.host?.contains("imgur") == true &&
      url.pathComponents.contains("a") == false &&
      url.pathComponents.contains("gallery") == false {
      return .imgur
    }

    if url.host?.contains("gfycat") == true {
      return .gfycat
    }

    if url.host?.contains("giphy.com") == true || url.host?.contains("gph.is") == true {
      return .giphy
    }

    if url.host?.contains("redgifs.com") == true {
      return .redgifs
    }

    if urlString.contains("i.redd.it") &&
      (url.pathExtension == "jpg" || url.pathExtension == "png") {
      return .reddit
    }
    
    if url.host?.contains("preview.redd.it") == true &&
      (url.pathExtension == "jpg" || url.pathExtension == "png" || url.queryValue(for: "format") == "mp4") {
      return .redditPreview
    }
    
    if url.host == "v.redd.it" && url.queryValue(for: "source") == "fallback" {
      return .redditVideo
    }

    return nil
  }

}
