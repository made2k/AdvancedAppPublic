//
//  AlbumFetchError.swift
//  Reddit
//
//  Created by made2k on 2/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

enum AlbumFetchError: Error {
  case primaryLoadFailed
  case invalidIdentifier
  case invalidJson
}
