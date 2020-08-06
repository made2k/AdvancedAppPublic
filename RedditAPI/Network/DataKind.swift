//
//  DataKind.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public enum DataKind: String, CaseIterable, Decodable {

  case comment = "t1"
  case account = "t2"
  case link = "t3"
  case message = "t4"
  case subreddit = "t5"
  case award = "t6"
  case trophyList = "TrophyList"
  case labeledMulti = "LabeledMulti"
  case listing = "Listing"
  case more = "more"
  case karmaList = "KarmaList"
  
  public static func type(from name: String) -> DataKind? {
    let prefix = String(name.prefix(2))
    return DataKind(rawValue: prefix)
  }

}
