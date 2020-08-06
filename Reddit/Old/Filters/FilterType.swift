//
//  FilterType.swift
//  Reddit
//
//  Created by made2k on 5/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

enum FilterType {
  case post
  case comment
}

enum FilterKind {
  case string
  case number
}

enum FilterSubtype {
  case subreddit
  case subject
  case author
  case flair
  case domain
  case commentCount
  case score
  
  var description: String {
    switch self {
    case .subreddit:
      return "Subreddit"
    case .subject:
      return "Subject"
    case .author:
      return "Author"
    case .domain:
      return "Domain"
    case .score:
      return "Score"
    case .flair:
      return "Flair"
    case .commentCount:
      return "Comment Count"
    }
  }
  
  var kind: FilterKind {
    switch self {
    case .subject, .author, .domain, .flair, .subreddit:
      return .string
    default:
      return .number
    }
  }

  
}
