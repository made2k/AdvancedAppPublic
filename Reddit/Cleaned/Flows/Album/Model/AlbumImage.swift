//
//  AlbumImage.swift
//  Reddit
//
//  Created by made2k on 3/5/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import SwiftyJSON

class AlbumImage: NSObject {
  let imageDescription: String?
  let url: URL
  let resolution: CGSize

  init(json: JSON) {
    let baseUrl = "https://i.imgur.com/"
    let hash = json["hash"].stringValue

    let isVideo = json["prefer_video"].boolValue ||
      (json["animated"].boolValue && json["looping"].boolValue)

    let jsonExt = json["ext"].stringValue

    let ext: String
    if jsonExt == ".gif" || jsonExt == ".gifv" {
      ext = isVideo ? ".mp4" : ".png"
    } else {
      ext = jsonExt.substringOrSelf(before: "?")
    }

    let width = json["width"].doubleValue
    let height = json["height"].doubleValue

    url = URL(string: baseUrl + hash + ext)!
    imageDescription =  json["description"].string
    resolution = CGSize(width: width, height: height)
  }
}
