//
//  TokenRefreshDelegate.swift
//  RedditAPI
//
//  Created by made2k on 6/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public protocol TokenRefreshDelegate: AnyObject {

  func tokenWasUpdated(_ token: Token)

}
