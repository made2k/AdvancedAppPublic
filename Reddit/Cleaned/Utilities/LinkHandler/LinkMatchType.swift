//
//  LinkMatchType.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import RedditAPI

enum LinkMatchType {
  case album(resolvedUrl: URL)
  case appStore(appStoreUrl: URL)
  case composeMessage(MessageComposeMatch)
  case media(unresolvedUrl: URL)
  case redditLink(SubredditLinkMatch)
  case redditListing(subreddit: String)
  case redditUser(userName: String)
  case redditSubmission(match: SubmissionMatch)
  case redditVideo(url: URL)
  case subredditWiki(resolvedUrl: URL)
  case table(tableData: String)
  case youtube(youtubeUrl: URL)
  case unknown(url: URL)
}
