//
//  ThingsResponse.swift
//  RedditAPI
//
//  Created by made2k on 3/31/20.
//  Copyright © 2020 made2k. All rights reserved.
//

struct ThingsResponse<T: Decodable>: Decodable {

  let things: [T]

  private enum CodingKeys: CodingKey {
    case things
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .things)

    var things: [T] = []

    while unkeyedContainer.isAtEnd == false {
      let thing = try unkeyedContainer.decode(T.self)
      things.append(thing)
    }

    self.things = things
  }

}
