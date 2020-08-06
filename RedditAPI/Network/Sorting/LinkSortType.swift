//
//  LinkSortType.swift
//  RedditAPI
//
//  Created by made2k on 6/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

/**
 Sorting used for displaying listings.
 This is meant to be appended to the listings
 endpoit.

 ```
 https://www.reddit.com/r/aww/<VALUE>
 ```
 */
public enum LinkSortType: String {
  case controversial
  case top
  case hot
  case new
  case rising
  // case best = ""
}
