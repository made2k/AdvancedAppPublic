//
//  APIContainer.swift
//  Reddit
//
//  Created by made2k on 2/15/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Logging
import RedditAPI

class APIContainer: NSObject {
  
  static let shared = APIContainer()
  
  let session = Session.shared
  
  private override init() {
    log.verbose("Created RedditAPI")
    
    let token = Keychain.shared.activeToken()
    session.token = token
    session.tokenDelegate = Keychain.shared
    
    super.init()
  }
  
}
