//
//  ListingsCoordinator+NSUserActivity.swift
//  Reddit
//
//  Created by made2k on 12/31/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Intents

extension ListingsCoordinator {

  func registerUserActivity(with display: ListingDisplay) {
    
    guard let controller = controller else { return }
    guard controller.userActivity == nil else { return }

    let displayName = display.title
    let queryString = display.queryable

    let activity = NSUserActivity(activityType: "com.advancedapp.Reddit.subredditVisit")

    activity.isEligibleForSearch = true
    activity.title = "Visit r/\(displayName)"

    activity.userInfo = [
      "subredditDisplayName": displayName,
      "subredditQuery": queryString
    ]
    activity.requiredUserInfoKeys = Set<String>(arrayLiteral: "subredditQuery", "subredditDisplayName")

    if #available(iOS 12.0, *) {
      activity.isEligibleForPrediction = true
      activity.persistentIdentifier = queryString
      activity.suggestedInvocationPhrase = "Show me \(displayName)"
    }

    controller.userActivity = activity

  }

}
