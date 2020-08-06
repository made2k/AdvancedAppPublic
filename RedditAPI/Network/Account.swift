//
//  Account.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

/**
 A representation of a signed in users account.
 This is the result of /api/v1/me. It is not used
 to represent a user. For that, see: User.swift
 */
public struct Account: Decodable {

  public static let kind = DataKind.account

  public let id: String
  public let userName: String
  public let created: Date
  public let isGold: Bool

  private enum CodingKeys: String, CodingKey {
    case id
    case userName = "name"
    case createdUtc
    case isGold
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    id = try values.decode(.id)
    userName = try values.decode(.userName)
    created = try values.decodeUtcDate(.createdUtc)
    isGold = try values.decode(.isGold)
  }

}
