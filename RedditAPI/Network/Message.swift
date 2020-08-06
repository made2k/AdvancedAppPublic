//
//  Message.swift
//  RedditAPI
//
//  Created by made2k on 6/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct Message: Decodable, EditableThing {

  public static let kind: DataKind = .message

  public let id: String
  public let name: String
  public let kind: DataKind
  public let parentName: String?
  public let parentType: DataKind?

  public let subreddit: String?
  public let subredditPrefixed: String?

  public let body: String
  public let bodyHtml: String
  public let subject: String
  public let author: String
  public let destination: String

  public let new: Bool
  public let created: Date
  public let distinguished: Distinguished?
  public let context: URL?

  // Link specific if comment
  public let linkTitle: String?
  public let score: Int

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case kind
    case wasComment
    case parentName = "parentId"
    case parentType
    case subreddit
    case subredditPrefixed = "subredditNamePrefixed"
    case body
    case bodyHtml
    case subject
    case author
    case destination = "dest"
    case new
    case created = "createdUtc"
    case distinguished
    case context
    case linkTitle
    case score
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(.id)
    self.name = try container.decode(.name)

    let wasComment: Bool = try container.decode(.wasComment)
    self.kind = wasComment ? .comment : .message

    self.parentName = try container.decodeIfPresent(.parentName)
    if let name = parentName {
      self.parentType = DataKind.type(from: name)
    } else {
      self.parentType = nil
    }

    self.subreddit = try container.decodeIfPresent(.subreddit)
    self.subredditPrefixed = try container.decodeIfPresent(.subredditPrefixed)

    self.body = try container.decode(.body)
    self.bodyHtml = try container.decode(.bodyHtml)
    self.subject = try container.decode(.subject)
    self.author = try container.decode(.author)
    self.destination = try container.decode(.destination)

    self.new = try container.decode(.new)
    self.created = try container.decodeUtcDate(.created)
    self.distinguished = try? container.decodeIfPresent(.distinguished)
    self.context = try container.decodeQualifiedUrlIfPresent(.context)

    self.linkTitle = try container.decodeIfPresent(.linkTitle)
    self.score = try container.decode(.score)
  }

}
