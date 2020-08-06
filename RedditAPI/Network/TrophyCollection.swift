//
//  TrophyCollection.swift
//  RedditAPI
//
//  Created by made2k on 3/8/20.
//  Copyright © 2020 made2k. All rights reserved.
//

struct TrophyCollection: Decodable {
  let trophies: [DataResponse<Trophy>]
}
