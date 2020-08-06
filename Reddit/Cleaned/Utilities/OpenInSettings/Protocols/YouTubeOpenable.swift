//
//  OpenInYouTube.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation
import UIKit

protocol YouTubeOpenable {

  static var scheme: String { get }

  static func openYoutubeLink(url: URL)

}

extension YouTubeOpenable {

  static var app: UIApplication {
    return UIApplication.shared
  }

}
