//
//  PromiseKit+Additions.swift
//  Reddit
//
//  Created by made2k on 9/10/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import PromiseKit

extension Promise {

  public class func error(_ value: Error) -> Promise<T> {
    return Promise(error: value)
  }

}

func attempt<T>(maximumRetryCount: Int = 3,
                delayBeforeRetry: DispatchTimeInterval = .seconds(1),
                _ body: @escaping () -> Promise<T>) -> Promise<T> {
  
  var attempts = 0
  
  func attempt() -> Promise<T> {
    attempts += 1
    
    return body().recover { error -> Promise<T> in
      guard attempts < maximumRetryCount else { throw error }
      return after(delayBeforeRetry).then(on: nil, attempt)
    }
  }
  
  return attempt()
}


