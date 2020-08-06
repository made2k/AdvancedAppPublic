//
//  Subreddit.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct Subreddit: Decodable {

  public let id: String
  public let name: String
  public static let type: DataKind = .subreddit

  // General info
  public let displayName: String
  public let displayNamePrefix: String
  public let iconImage: URL?
  public let subredditDescription: String
  public let subredditDescriptionHtml: String?
  public let over18: Bool
  public let activeUserCount: Int?
  public let subscriberCount: Int

  // Submissions
  public let submitText: String?
  public let submitTextHtml: String?
  public let submissionType: SubmissionType

  // User Info
  public let userIsSubscriber: Bool

  // Misc Info
  public let created: Date
  public let title: String

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case displayName
    case displayNamePrefix = "displayNamePrefixed"
    case iconImage = "iconImg"
    case subredditDescription = "description"
    case subredditDescriptionHtml = "descriptionHtml"
    case over18
    case activeUserCount
    case subscriberCount = "subscribers"
    case submitText
    case submitTextHtml
    case submissionType
    case userIsSubscriber
    case created = "createdUtc"
    case title
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(.id)
    name = try container.decode(.name)
    displayName = try container.decode(.displayName)
    displayNamePrefix = try container.decode(.displayNamePrefix)
    iconImage = try? container.decodeIfPresent(.iconImage)
    subredditDescription = try container.decode(.subredditDescription)
    subredditDescriptionHtml = try container.decode(.subredditDescriptionHtml)
    over18 = try container.decode(.over18)
    activeUserCount = try container.decode(.activeUserCount)
    subscriberCount = try container.decode(.subscriberCount)
    submitText = try container.decode(.submitText)
    submitTextHtml = try container.decode(.submitTextHtml)
    submissionType = try container.decode(.submissionType)
    userIsSubscriber = (try container.decodeIfPresent(.userIsSubscriber)) ?? false
    created = try container.decodeUtcDate(.created)
    title = try container.decode(.title)

  }

}
