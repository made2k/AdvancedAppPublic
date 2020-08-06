//
//  APIError.swift
//  RedditAPI
//
//  Created by made2k on 6/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import SwiftyJSON

public enum APIError: Error {
  case alreadySubmitted
  case badResponse
  case internalError
  case notSignedIn
  case rateLimit(message: String)
  case unknown

  static func parseError(array: [JSON]) -> APIError {

    guard let errorArray = array.map(\.arrayValue).first else {
      return .unknown
    }

    let errorMessageArray = errorArray.map(\.stringValue)
    
    if errorMessageArray.contains("ALREADY_SUB") {
      return .alreadySubmitted
    }

    if errorMessageArray.contains("RATELIMIT") {
      let message = errorMessageArray[safe: 1] ?? "Try again in a few minutes"
      return .rateLimit(message: message)
    }

    return .unknown
  }

}
