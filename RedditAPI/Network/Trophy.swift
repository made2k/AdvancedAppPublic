//
//  Trophy.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct Trophy: Decodable {

  public static let kind: DataKind = .award

  public let name: String
  public let icon70: URL
  public let icon40: URL
}
