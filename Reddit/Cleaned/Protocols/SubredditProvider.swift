//
//  SubredditProvider.swift
//  Reddit
//
//  Created by made2k on 2/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

protocol SubredditProvider {

  var subredditModel: SubredditModel? { get }
  var subredditName: String? { get }

}
