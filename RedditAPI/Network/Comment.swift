//
//  Comment.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct Comment: Decodable, DeleteType, EditableThing, SaveType, VoteType {

  public static let kind: DataKind = .comment

  public let id: String
  public let name: String

  public let score: Int
  public let scoreHidden: Bool
  public let direction: VoteDirection

  public let saved: Bool
  public let stickied: Bool

  public let linkId: String
  public let parentName: String
  public let created: Date
  public let archived: Bool

  public let author: String
  public let body: String
  public let bodyHtml: String
  public let distinguished: Distinguished?
  public let flair: Flair?

  public let gildings: Gildings

  public let subreddit: String?
  public let permaLink: URL

  public let children: [CommentType]

  // User comment, found when querying comments for a user instead of a listing
  public let linkTitle: String?
  public let linkCommentCount: Int?
  public let linkAuthor: String?
  public let linkPermalink: URL?
  public let linkContentUrl: URL?

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case score
    case scoreHidden
    case direction = "likes"
    case saved
    case stickied
    case linkId
    case parentName = "parentId"
    case created = "createdUtc"
    case archived
    case author
    case body
    case bodyHtml
    case distinguished
    case flair = "authorFlairRichtext"
    case flairBackgroundColor = "authorFlairBackgroundColor"
    case gildings
    case subreddit
    case permalink
    case children = "replies"

    case linkTitle
    case linkCommentCount = "numComments"
    case linkAuthor
    case linkPermalink
    case linkContentUrl = "linkUrl"

    case isSubmitter
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(.id)
    name = try container.decode(.name)
    score = try container.decode(.score)
    scoreHidden = try container.decode(.scoreHidden)
    direction = container.decodeVoteDirection(.direction)
    saved = try container.decode(.saved)
    stickied = try container.decode(.stickied)
    linkId = try container.decode(.linkId)
    parentName = try container.decode(.parentName)
    created = try container.decodeUtcDate(.created)
    archived = try container.decode(.archived)
    author = try container.decode(.author)
    body = try container.decode(.body)
    bodyHtml = try container.decode(.bodyHtml)

    if let decodedDistinguished: Distinguished = try? container.decode(.distinguished) {
      distinguished = decodedDistinguished

    } else if let isSubmitter: Bool = try container.decode(.isSubmitter), isSubmitter {
      distinguished = .submitter

    } else {
      distinguished = nil
    }

    let decodedFlair: Flair? = try container.decodeIfPresent(.flair)
    if
      let flair = decodedFlair,
      let flairColorString: String = try container.decodeIfPresent(.flairBackgroundColor),
      let flairColor = UIColor(hexString: flairColorString)
    {
      self.flair = Flair(flair: flair, backgroundColor: flairColor)

    } else {
      self.flair = decodedFlair
    }

    gildings = try container.decode(.gildings)
    subreddit = try container.decode(.subreddit)
    permaLink = try container.decodeQualifiedUrl(.permalink)

    if let replies: DataResponse<PagingDataResponse<DataResponse<CommentTypeParser>>> = try? container.decode(.children) {

      children = replies.data.children
        .map(\.data.commentType)
        .filterEmpty()

    } else {
      children = []
    }

    linkTitle = try? container.decodeIfPresent(.linkTitle)
    linkCommentCount = try? container.decodeIfPresent(.linkCommentCount)
    linkAuthor = try? container.decodeIfPresent(.linkAuthor)
    linkPermalink = try? container.decodeIfPresent(.linkPermalink)
    linkContentUrl = try? container.decodeIfPresent(.linkContentUrl)
  }

  init(comment: Comment, children: [CommentType]) {
    self.id = comment.id
    self.name = comment.name
    self.score = comment.score
    self.scoreHidden = comment.scoreHidden
    self.direction = comment.direction
    self.saved = comment.saved
    self.stickied = comment.stickied
    self.linkId = comment.linkId
    self.parentName = comment.parentName
    self.created = comment.created
    self.archived = comment.archived
    self.author = comment.author
    self.body = comment.body
    self.bodyHtml = comment.bodyHtml
    self.distinguished = comment.distinguished
    self.flair = comment.flair
    self.gildings = comment.gildings
    self.subreddit = comment.subreddit
    self.permaLink = comment.permaLink
    self.children = children
    self.linkTitle = comment.linkTitle
    self.linkCommentCount = comment.linkCommentCount
    self.linkAuthor = comment.linkAuthor
    self.linkPermalink = comment.linkPermalink
    self.linkContentUrl = comment.linkContentUrl
  }

}
