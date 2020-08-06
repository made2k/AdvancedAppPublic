//
//  More.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct More: Decodable {

  public let id: String
  public let name: String
  public let parentName: String
  public let childrenIds: [String]

  public var count: Int {
    childrenIds.count
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case parentName = "parentId"
    case childrenIds = "children"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(.id)
    name = try container.decode(.name)
    parentName = try container.decode(.parentName)

    var childIdContainer = try container.nestedUnkeyedContainer(forKey: .childrenIds)
    var childIds: [String] = []

    while childIdContainer.isAtEnd == false {
      let id = try childIdContainer.decode(String.self)
      childIds.append(id)
    }

    childrenIds = childIds
  }

}
