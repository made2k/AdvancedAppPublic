//
//  SubmissionType.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public enum SubmissionType: String, Decodable {
  case any = "any"
  case link = "link"
  case selftext = "self"
}
