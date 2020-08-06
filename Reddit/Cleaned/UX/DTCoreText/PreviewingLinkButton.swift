//
//  PreviewingLinkButton.swift
//  Reddit
//
//  Created by made2k on 2/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import DTCoreText
import Foundation

final class PreviewingLinkButton: DTLinkButton {
  
  private var context: ContextMenu?
  
  private var isValidUrl: Bool {
    return url.absoluteString.hasPrefix("#") == false &&
      url.scheme != URL.CustomSchemes.spoiler
  }
  
  convenience init(frame: CGRect, url: URL, identifier: String) {
    self.init(frame: frame)
    
    self.url = url
    self.guid = identifier
    
    if isValidUrl {
      context = ParentContextUrlPreview(url: url)
      context?.register(view: self)
    }

    // If we don't have a valid URL (like a spoiler)
    // Give the button the rounded appearance
    if isValidUrl == false {
      layer.cornerRadius = 3
      clipsToBounds = true
      showsTouchWhenHighlighted = true
      
    } else {
      showsTouchWhenHighlighted = false
    }

  }
  
}
