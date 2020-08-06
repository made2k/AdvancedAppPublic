//
//  AuthenticationError.swift
//  RedditAPI
//
//  Created by made2k on 6/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

enum AuthenticationError: Error {
  case invalidToken
  case unauthorized
}
