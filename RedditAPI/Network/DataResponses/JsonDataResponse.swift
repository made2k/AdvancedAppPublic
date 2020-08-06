//
//  JsonDataResponse.swift
//  RedditAPI
//
//  Created by made2k on 4/1/20.
//  Copyright © 2020 made2k. All rights reserved.
//

struct JsonDataResponse<T: Decodable>: Decodable {

  let data: T

  private enum JsonCodingKeys: CodingKey {
    case json
  }

  private enum DataContainer: CodingKey {
    case data
  }

  init(from decoder: Decoder) throws {
    let jsonContainer = try decoder.container(keyedBy: JsonCodingKeys.self)
    let dataContainer = try jsonContainer.nestedContainer(keyedBy: DataContainer.self, forKey: .json)

    data = try dataContainer.decode(T.self, forKey: .data)
  }

}
