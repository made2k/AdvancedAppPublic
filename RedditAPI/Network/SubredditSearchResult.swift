//
//  SubredditSearchResult.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

public struct SubredditSearchResult: Decodable {

  public let name: String
  public let icon: URL?
  public let subscriberCount: Int
  public let activeUserCount: Int

  private enum CodingKeys: String, CodingKey {
    case name
    case icon = "iconImg"
    case subscriberCount
    case activeUserCount
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    name = try container.decode(.name)
    icon = try? container.decode(.icon)
    subscriberCount = try container.decode(.subscriberCount)
    activeUserCount = try container.decode(.activeUserCount)
  }

  public init(name: String) {
    self.name = name
    self.icon = nil
    self.subscriberCount = 0
    self.activeUserCount = 0
  }

}

extension SubredditSearchResult: Equatable {
  
  public static func == (lhs: SubredditSearchResult, rhs: SubredditSearchResult) -> Bool {
    return lhs.name == rhs.name
  }
  
}
