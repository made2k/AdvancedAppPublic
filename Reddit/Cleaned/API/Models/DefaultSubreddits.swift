//
//  DefaultSubreddits.swift
//  Reddit
//
//  Created by made2k on 5/2/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import PromiseKit
import SwiftyJSON

class DefaultSubreddits: NSObject {

  static func userDefault() -> Guarantee<ListingDisplay> {

    let startSubredditString = Settings.startOnSubreddit

    if startSubredditString.hasPrefix("multi-") {
      return loadFeed(startSubredditString)

    } else if let userSubreddit = UserSubreddit.fromPath(startSubredditString) {
      return loadUserSubreddit(userSubreddit)

    } else {

      return firstly {
        SubredditModel.verifySubredditExists(path: startSubredditString)

      }.recover { _ in
        return .value(front())
        
      }.map {
        return $0 as ListingDisplay
      }
    }
    
  }
  
  static func front() -> SubredditModel {
    return SubredditModel(userSubreddit: .front)
  }
  
  static func popular() -> SubredditModel {
    return SubredditModel(userSubreddit: .popular)
  }
  
  static func all() -> SubredditModel {
    return SubredditModel(userSubreddit: .all)
  }
  
  static func random() -> SubredditModel {
    return SubredditModel(userSubreddit: .random)
  }
  
  // MARK: - Loaders
  
  private static func loadFeed(_ query: String) -> Guarantee<ListingDisplay> {
    let feedName = query.substringOrSelf(after: "multi-")
    
    return firstly {
      FeedModel.loadUserFeed(feedName: feedName)
      
    }.map {
      return $0 as ListingDisplay
      
    }.recover { _ -> Guarantee<ListingDisplay> in
      return .value(front())
    }
    
  }
  
  private static func loadUserSubreddit(_ userSub: UserSubreddit) -> Guarantee<ListingDisplay> {
    let model = SubredditModel(userSubreddit: userSub)
    return .value(model)
  }
  
  private static func loadSubreddit(_ subredditName: String) -> Guarantee<ListingDisplay> {
    
    return firstly {
      SubredditModel.verifySubredditExists(path: subredditName)
      
    }.map {
      return $0 as ListingDisplay
      
    }.recover { _ in
      return .value(front())
        
    }
    
  }

}
