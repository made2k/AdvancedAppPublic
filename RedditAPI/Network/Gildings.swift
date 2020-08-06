//
//  Gildings.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct Gildings: Decodable {

  public var platinum: Int
  public var gold: Int
  public var silver: Int

  private enum CodingKeys: String, CodingKey {
    case platinum = "gid3"
    case gold = "gid2"
    case silver = "gid1"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    platinum = try container.decodeIfPresent(.platinum) ?? 0
    gold = try container.decodeIfPresent(.gold) ?? 0
    silver = try container.decodeIfPresent(.silver) ?? 0
  }

}
