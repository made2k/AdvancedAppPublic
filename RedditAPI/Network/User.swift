//
//  User.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct User: Decodable {

  public let id: String
  public let name: String
  public var icon: URL?
  public let commentKarma: Int
  public let linkKarma: Int
  public let created: Date

  private enum CodingKeys: String, CodingKey {
      case id
      case name
      case icon = "iconImg"
      case commentKarma
      case linkKarma
      case createdUtc
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(.id)
    name = try container.decode(.name)
    icon = try container.decodeIfPresent(.icon)
    commentKarma = try container.decode(.commentKarma)
    linkKarma = try container.decode(.linkKarma)
    created = try container.decodeUtcDate(.createdUtc)
  }

}
