//
//  MediaExtractionError.swift
//  Reddit
//
//  Created by made2k on 6/3/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

enum MediaExtractionError: Error {
  case mediaNotSupported
  case mediaUrlNotFound
  case unknown
}
