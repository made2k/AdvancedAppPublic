//
//  Link.swift
//  RedditAPI
//
//  Created by made2k on 6/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Utilities

public struct Link: Decodable, DeleteType, EditableThing, SaveType, VoteType {
  
  // Standard Thing

  public let id: String
  public let name: String
  public static let kind: DataKind = .link

  // Link Info

  public let title: String
  public let thumbnail: URL?
  public let author: String
  public let edited: Date?
  public let flair: Flair?
  public let gildings: Gildings
  public let domain: String?
  public let upvoteRatio: Double?
  public let commentCount: Int
  public let created: Date
  public let permalink: URL?

  public let score: Int
  public let direction: VoteDirection

  // Link Status

  public let stickied: Bool
  public let spoiler: Bool
  public let pinned: Bool
  public let archived: Bool
  public let over18: Bool
  public let locked: Bool

  // Subreddit info

  public let subreddit: String
  public let subredditNamePrefixed: String

  // User Info

  public let saved: Bool
  public let hidden: Bool
  public let visited: Bool

  // Content Info

  public let url: URL?
  public let selftextHtml: String?
  public let selftext: String?
  public let isSelf: Bool
  public let media: RedditVideo?
  public let preview: Preview?
  public let postHint: String?

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case title
    case linkTitle
    case thumbnail
    case author
    case edited
    case flair = "linkFlairRichtext"
    case flairBackgroundColor = "linkFlairBackgroundColor"
    case gildings
    case domain
    case upvoteRatio
    case commentCount = "numComments"
    case created = "createdUtc"
    case permalink
    case score
    case direction = "likes"
    case stickied
    case spoiler
    case pinned
    case archived
    case over18
    case locked
    case subreddit
    case subredditNamePrefixed
    case saved
    case hidden
    case visited
    case url
    case selftextHtml
    case selftext
    case isSelf
    case media
    case crosspostParentList
    case preview
    case postHint
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(.id)
    self.name = try container.decode(.name)
    if let titleString: String = try container.decode(.title) {
      self.title = titleString

    } else {
      self.title = try container.decode(.linkTitle)
    }

    self.thumbnail = try? container.decodeIfPresent(.thumbnail)
    self.author = try container.decode(.author)
    self.edited = try? container.decodeUtcDate(.edited)

    if
      let flair: Flair = try? container.decodeIfPresent(.flair),
      let flairColorString: String = try? container.decodeIfPresent(.flairBackgroundColor),
      let flairColor = UIColor(hexString: flairColorString)
    {
      self.flair = Flair(flair: flair, backgroundColor: flairColor)

    } else {
      flair = try? container.decodeIfPresent(.flair)
    }

    self.gildings = try container.decode(.gildings)
    if let domainString: String = try? container.decode(.domain) {
      self.domain = domainString

    } else if let _: String = try? container.decodeNonEmptyStringIfPresent(.selftext) {
      self.domain = "self.reddit"

    } else {
      self.domain = nil
    }
    self.upvoteRatio = try container.decodeIfPresent(.upvoteRatio)
    self.commentCount = try container.decode(.commentCount)
    self.created = try container.decodeUtcDate(.created)
    self.permalink = try container.decodeQualifiedUrl(.permalink)
    self.score = try container.decode(.score)
    self.direction = container.decodeVoteDirection(.direction)
    self.stickied = try container.decode(.stickied)
    self.spoiler = try container.decode(.spoiler)
    self.pinned = try container.decode(.pinned)
    self.archived = try container.decode(.archived)
    self.over18 = try container.decode(.over18)
    self.locked = try container.decode(.locked)
    self.subreddit = try container.decode(.subreddit)
    self.subredditNamePrefixed = try container.decode(.subredditNamePrefixed)
    self.saved = try container.decode(.saved)
    self.hidden = try container.decode(.hidden)
    self.visited = try container.decode(.visited)
    self.url = try container.decodeQualifiedUrlIfPresent(.url)
    self.selftext = try container.decodeNonEmptyStringIfPresent(.selftext)
    self.selftextHtml = try container.decodeNonEmptyStringIfPresent(.selftextHtml)
    if let value: Bool = try container.decodeIfPresent(.isSelf) {
      self.isSelf = value
    } else {
      self.isSelf = self.selftext != nil
    }
    if let value: Media = try? container.decode(.media) {
      self.media = value.redditVideo

    } else if
      let parentList: [Link] = try? container.decode(.crosspostParentList),
      let crossPost: Link = parentList.first
    {
      self.media = crossPost.media

    } else {
      self.media = nil
    }
    self.preview = try container.decodeIfPresent(.preview)
    self.postHint = try container.decodeIfPresent(.postHint)
  }

}
