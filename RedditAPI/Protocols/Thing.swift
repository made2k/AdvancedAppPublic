//
//  Thing.swift
//  RedditAPI
//
//  Created by made2k on 6/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public protocol Thing {

  var id: String { get }
  var name: String { get }
  static var kind: DataKind { get }

}

extension Thing {

  public var kind: DataKind {

    for type in DataKind.allCases {
      if name.hasPrefix(type.rawValue) {
        return type
      }
    }

    fatalError("unknown type of thing")
  }

}
