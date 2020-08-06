//
//  KarmaListSubreddit.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

/**
 This represents data received when quering the subreddits
 that a user is active in.
 */
public struct KarmaListSubreddit: Decodable {

  public let displayName: String
  public let displayNamePrefixed: String

  public let icon: URL?
  public let communityIcon: URL?

  public let subscriberCount: Int

  private enum CodingKeys: String, CodingKey {
    case displayName = "sr"
    case displayNamePrefixed = "srDisplayNamePrefixed"
    case icon = "iconImg"
    case communityIcon = "communityIcon"
    case subscriberCount = "subscribers"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.displayName = try container.decode(.displayName)
    self.displayNamePrefixed = try container.decode(.displayNamePrefixed)
    self.icon = try? container.decode(.icon)
    self.communityIcon = try? container.decode(.communityIcon)
    self.subscriberCount = try container.decode(.subscriberCount)
  }

}
