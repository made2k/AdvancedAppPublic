//
//  LinkMatcher.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

struct LinkMatcher {
  
  static func matchUrl(_ url: URL) -> LinkMatchType {

    if let tableData = TableLinkMatcher.match(url) {
      return .table(tableData: tableData)
    }

    if let url = RedditWikiMatcher.match(url) {
      return .subredditWiki(resolvedUrl: url)
    }
    
    if let url = AlbumMatcher.matchAlbum(url) {
      return .album(resolvedUrl: url)
    }
    
    if let url = AppStoreMatcher.match(url) {
      return .appStore(appStoreUrl: url)
    }
    
    if let match = MessageComposeUrlMatcher.match(url) {
      return .composeMessage(match)
    }
    
    if let url = ImageLinkMatcher.match(url) {
      return .media(unresolvedUrl: url)
    }
    
    if let match = SubredditLinkMatcher.match(url) {
      return .redditLink(match)
    }
    
    if let match = SubredditSubmissionMatcher.match(url) {
      return .redditSubmission(match: match)
    }

    if let subreddit = SubredditListingMatcher.match(url) {
      return .redditListing(subreddit: subreddit)
    }

    if let user = RedditUserMatcher.match(url) {
      return .redditUser(userName: user)
    }
    
    if let match = SubredditSubmissionMatcher.match(url) {
      return .redditSubmission(match: match)
    }
    
    if let url = RedditVideoMatcher.match(url) {
      return .redditVideo(url: url)
    }

    if let url = YouTubeLinkMatcher.match(url) {
      return .youtube(youtubeUrl: url)
    }
    
    return .unknown(url: url)
  }
  

}
