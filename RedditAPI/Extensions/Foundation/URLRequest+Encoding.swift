//
//  URLRequest+Encoding.swift
//  RedditAPI
//
//  Created by made2k on 4/1/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Foundation

/*
 Collection of functions taken from Alamofire to help with
 encoding a url request
 */

extension URLRequest {

  mutating func encode(with parameters: [String: Encodable]) throws {
    setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
    httpBody = Data(query(parameters).utf8)
  }

  private func query(_ parameters: [String: Any]) -> String {
    var components: [(String, String)] = []

    for key in parameters.keys.sorted(by: <) {
      let value = parameters[key]!
      components += queryComponents(fromKey: key, value: value)
    }

    return components
      .map { "\($0)=\($1)" }
      .joined(separator: "&")
  }

  public func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
    var components: [(String, String)] = []

    if let dictionary = value as? [String: Any] {

      for (nestedKey, value) in dictionary {
        components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
      }

    } else if let array = value as? [Any] {

      for value in array {
        components += queryComponents(fromKey: key, value: value)
      }

    } else if let value = value as? NSNumber {

      if value.isBool {
        components.append((escape(key), escape(BoolEncoding.encode(value: value.boolValue))))
      } else {
        components.append((escape(key), escape("\(value)")))
      }

    } else if let bool = value as? Bool {
      components.append((escape(key), escape(BoolEncoding.encode(value: bool))))

    } else {
      components.append((escape(key), escape("\(value)")))

    }

    return components
  }

  private func escape(_ string: String) -> String {
    string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
  }

  private enum BoolEncoding {

    static func encode(value: Bool) -> String {
      value ? "1" : "0"
    }
  }

}

private extension NSNumber {

  var isBool: Bool {
    // Use Obj-C type encoding to check whether the underlying type is a `Bool`, as it's guaranteed as part of
    // swift-corelibs-foundation, per [this discussion on the Swift forums](https://forums.swift.org/t/alamofire-on-linux-possible-but-not-release-ready/34553/22).
    String(cString: objCType) == "c"
  }
}
