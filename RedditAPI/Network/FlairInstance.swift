//
//  FlairInstance.swift
//  RedditAPI
//
//  Created by made2k on 4/1/20.
//  Copyright © 2020 made2k. All rights reserved.
//

internal enum FlairInstance: Decodable {

  case emoji(url: URL)
  case text(value: String)

  private enum CodingKeys: String, CodingKey {
    case imageUrl = "u"
    case flairType = "e"
    case text = "t"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    let type: String = try values.decode(.flairType)

    switch type {

    case "emoji":
      let url: URL = try values.decode(.imageUrl)
      self = .emoji(url: url)

    case "text":
      let value: String = try values.decode(.text)
      self = .text(value: value)

    default:
      let context = DecodingError.Context(
        codingPath: [CodingKeys.flairType],
        debugDescription: "Flair type did not contain expected value."
      )
      throw DecodingError.dataCorrupted(context)

    }

  }

}
