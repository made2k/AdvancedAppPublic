//
//  URL+Additions.swift
//  Reddit
//
//  Created by made2k on 9/11/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit

extension URL {
  
  /**
   The path components of the URL ignoring dashes,
   or an empty array if the path is an empty string.
   */
  var sanitizedPathComponents: [String] {
    return pathComponents
      .filter { $0 != "/" }
      .map { $0.substringOrSelf(before: ".") }
  }

  // TODO: Further testing to see if this can be used for normal sanitized path componetns
  // This was used for matching the link https://www.reddit.com/r/reddit.com/comments/xmyy/apple_iphone_now_real/
  // Not sure if getting rid of the substring or self breaks anything else
  var sanitizedPathComponentsAllowingDots: [String] {
    return pathComponents
      .filter { $0 != "/" }
  }
  
  /**
   Check if the url is valid by making a request to the url
   and validating the return status. If the response status
   code is 200..<400, this will resolve the promise with the
   url.
   */
  func checkIfValid() -> Promise<URL> {
    
    return AF.request(self)
      .validate(statusCode: 200..<400)
      .responseData()
      .map { _ in self }
    
  }
  
  /**
   Make sure the url has a scheme of http or https. Construct a new URL
   if the current url does not have a scheme.
   */
  func safeScheme() -> URL {
    
    guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
      return self
    }
    
    if components.scheme == nil || components.scheme != "https" || components.scheme != "http" {
      components.scheme = "https"
    }
    
    return components.url ?? self
  }
  
  /// Attempt to extract a youtube style timestamp from the url
  func videoTimeStamp() -> TimeInterval? {
    
    guard let string = queryParameters?["t"] else { return nil }
    
    let h = string.substring(before: "h")
    let m = string.substring(before: "m")?.substringOrSelf(after: "h")
    let s = string.substring(before: "s")?.substringOrSelf(after: "m")

    // If we don't have any dedicated durations, we need to assume seconds
    if h == nil && m == nil && s == nil {
      return TimeInterval(string: string)
    }
    
    let hours: Int = h != nil ? (Int(h!) ?? 0) : 0
    let minutes: Int = m != nil ? (Int(m!) ?? 0) : 0
    let seconds: Int = s != nil ? (Int(s!) ?? 0) : 0
    
    let interval = hours * 60 * 60 + minutes * 60 + seconds
    return TimeInterval(interval)
  }

  func isRedditMedia() -> Bool {
    return self.host == "i.redd.it"
  }
  
  func isUnsupportedRedditGif() -> Bool {
    return isRedditMedia() && self.pathExtension == "gif"
  }

}
