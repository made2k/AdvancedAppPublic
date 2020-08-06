//
//  Feed.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct Feed: Decodable {

  public let name: String
  public let displayName: String
  public let iconUrl: URL?
  public let path: String
  internal let subredditNames: [NamedSubreddit]
  public var subreddits: [String] {
    subredditNames.map(\.name)
  }
  public let over18: Bool
  public let owner: String
  public let canEdit: Bool
  public let descriptionHtml: String?
  public let descriptionMarkdown: String?

  private enum CodingKeys: String, CodingKey {
    case name
    case displayName
    case iconUrl
    case path
    case subreddits
    case owner
    case canEdit
    case descriptionHtml
    case descriptionMarkdown = "description_md"
    case created
    case over18
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    name = try values.decode(.name)
    displayName = try values.decode(.displayName)
    iconUrl = try values.decodeIfPresent(.iconUrl)
    path = try values.decode(.path)
    subredditNames = try values.decodeIfPresent(.subreddits) ?? []
    over18 = try values.decode(.over18)
    owner = try values.decode(.owner)
    canEdit = try values.decode(.canEdit)
    descriptionMarkdown = try values.decodeNonEmptyStringIfPresent(.descriptionMarkdown)
    descriptionHtml = try? values.decodeNonEmptyStringIfPresent(.descriptionHtml)
  }

}
