//
//  ImageExtractorRecord.swift
//  Reddit
//
//  Created by made2k on 1/14/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation
import RealmSwift

class ImageExtractorRecord: Object {

  @objc dynamic var lookup: String = ""
  @objc dynamic var urlString: String? = nil
  @objc dynamic var stringType: String = ""

  var imageType: ImageType? {
    return ImageType(rawValue: stringType)
  }

  var url: URL? {
    guard let urlString = urlString else { return nil }
    return URL(string: urlString)
  }

}
