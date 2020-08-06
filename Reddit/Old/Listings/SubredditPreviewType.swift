//
//  SubredditPreviewType.swift
//  Reddit
//
//  Created by made2k on 11/6/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation
import RealmSwift

enum PreviewType: String {
  case thumbnail = "thumbnail"
  case preview = "preview"

  static func previewType(for key: String?) -> PreviewType {

    let defaultValue: PreviewType = Settings.showPreview.value ? .preview : .thumbnail
    
    guard Settings.previewTypePerSubreddit == true else { return defaultValue }
    guard let key = key?.lowercasedTrim else { return defaultValue }

    if let previewType = try? Realm()
      .objects(SubredditPreviewType.self)
      .filter("subreddit = '\(key)'")
      .first?
      .previewType {

      return PreviewType(rawValue: previewType) ?? defaultValue

    } else {
      return defaultValue
    }

  }

}

class SubredditPreviewType: Object {
  @objc dynamic var subreddit: String = ""
  @objc dynamic var previewType: String = ""
  
  convenience init(_ subreddit: String, previewType: PreviewType) {
    self.init()
    self.subreddit = subreddit
    self.previewType = previewType.rawValue
  }
  
  override static func primaryKey() -> String? {
    return "subreddit"
  }
}

