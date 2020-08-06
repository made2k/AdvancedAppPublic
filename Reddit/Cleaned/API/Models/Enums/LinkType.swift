//
//  LinkType.swift
//  Reddit
//
//  Created by made2k on 6/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

enum LinkType {
  case selfText
  case article
  case image
  case video
  case unknown

  static func guessType(for link: Link) -> LinkType {

    if link.selftext != nil { return .selfText }
    
    // Here we attempt to find a reddit video. Deliberately
    // ignore a gif to see if our image extractor supports
    // the url first before potentially falling back to the
    // reddit media gif
    if let media = link.media, media.isGif == false {
      return LinkType.video
    }

    if let url = link.url, ImageExtractor.shared.supportsLink(url: url) {
      return LinkType.image
    }

    if let mediaGif = link.media, mediaGif.isGif {
       return LinkType.image
    }

    if link.postHint == "image" {
      return LinkType.image
    }
    
    if
      let domain = link.domain,
      VideoExtractor.providerType(domain: domain) != .none {
      return LinkType.video
    }

    if let url = link.url,
      url.host?.contains("reddit.com") == true &&
        url.path.contains("/\(link.id)/") {
      // We've received a reddit link that's not a self text
      return LinkType.unknown
    }

    return link.url != nil ? LinkType.article : LinkType.unknown
  }
  
}
