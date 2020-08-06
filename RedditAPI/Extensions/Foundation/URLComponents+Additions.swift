//
//  URLComponents+Additions.swift
//  RedditAPI
//
//  Created by made2k on 4/1/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension URLComponents {

  func asURL() throws -> URL {
    guard let url = url else {
      throw RequestFormatError.invalid
    }

    return url
  }

}
