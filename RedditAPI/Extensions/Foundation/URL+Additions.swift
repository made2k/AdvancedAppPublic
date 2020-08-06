//
//  URL+Additions.swift
//  RedditAPI
//
//  Created by made2k on 3/20/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension URL {

  init(staticString string: StaticString) {
    guard let url = URL(string: "\(string)") else {
      preconditionFailure("Invalid static URL string: \(string)")
    }

    self = url
  }

}
