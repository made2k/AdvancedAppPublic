//
//  NetworkControllerDelegate.swift
//  RedditAPI
//
//  Created by made2k on 4/1/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import PromiseKit

protocol NetworkControllerDelegate: AnyObject {

  func refreshToken(_ token: Token, on queue: DispatchQueue) throws -> Promise<Token>
  func responseReceived(_ response: URLResponse)

}
