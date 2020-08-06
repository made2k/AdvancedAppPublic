//
//  APIError.swift
//  Reddit
//
//  Created by made2k on 9/10/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import SwiftyJSON

enum OldAPIError: Error {
  case unknown
  case notSignedIn
  case invalidRequest
  case alreadySubmitted
  case rateLimit
  
  static func parseError(json: JSON) -> OldAPIError {
    // TODO: implement
    return .unknown
  }
  
  static func parseError(array: [JSON]) -> OldAPIError {
    let mapped = array.map({ $0.stringValue })
    if mapped.contains("ALREADY_SUB") {
      return .alreadySubmitted
    }
    if mapped.contains("RATELIMIT") {
      return .rateLimit
    }
    
    return .unknown
  }
}

enum ICloudError: Error {
  case unknown
  case notAutorized
}

enum NetworkError: Error {
  case invalidURL
}

enum ApplicationError: Error {
  case objectDeallocated
  case unsupportedUrlScheme
}

enum GenericError: Error {
  case error
}
