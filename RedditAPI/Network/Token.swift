//
//  Token.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct Token: Codable, Equatable {

  public let name: String?
  public let tokenType: String
  public let accessToken: String
  public let refreshToken: String?
  public let scope: String
  public let expirationDate: Date

  public var isExpired: Bool {
    return Date() >= expirationDate
  }

  private enum CodingKeys: String, CodingKey {
    case name
    case tokenType
    case accessToken
    case refreshToken
    case scope
    case expiresIn// = "expiresIn"
    case expireDate
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.name = try container.decodeIfPresent(.name)
    self.tokenType = try container.decode(.tokenType)
    self.accessToken = try container.decode(.accessToken)
    self.refreshToken = try container.decodeIfPresent(.refreshToken)
    self.scope = try container.decode(.scope)
    
    /*
     When receiving a token from Reddit, it has an expiration interval,
     when loading from disk, it has an expiration date.
     */
    if let expireDate: Date = try? container.decodeUtcDate(.expireDate) {
      self.expirationDate = expireDate

    } else {
      let expiryInterval: TimeInterval = try container.decode(.expiresIn)
      self.expirationDate = Date(timeInterval: -60, since: Date()).addingTimeInterval(expiryInterval)
    }

  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encodeIfPresent(name, forKey: .name)
    try container.encode(tokenType, forKey: .tokenType)
    try container.encode(accessToken, forKey: .accessToken)
    try container.encodeIfPresent(refreshToken, forKey: .refreshToken)
    try container.encode(scope, forKey: .scope)

    let interval = expirationDate.timeIntervalSince1970
    try container.encode(interval, forKey: .expireDate)
  }

  /**
   This initializer is used when refreshing a token. The API will only give
   back the new access token along with the expiration date. The rest
   of the token remains the same. This new token is created using the unchanged
   parts of the old token and the new parameters

   - Parameters:
   - accessToken: The new access token.
   - expirationDate: Date the token will expire.
   - token: The existing token that values will be copied from.
   */
  init(accessToken: String, expirationDate: Date, token: Token) {
    self.accessToken = accessToken
    self.expirationDate = expirationDate

    self.name = token.name
    self.tokenType = token.tokenType
    self.refreshToken = token.refreshToken
    self.scope = token.scope
  }

  init(name: String, token: Token) {
    self.name = name

    self.tokenType = token.tokenType
    self.accessToken = token.accessToken
    self.refreshToken = token.refreshToken
    self.scope = token.scope
    self.expirationDate = token.expirationDate
  }

}
