//
//  DataResponse.swift
//  RedditAPI
//
//  Created by made2k on 3/8/20.
//  Copyright © 2020 made2k. All rights reserved.
//

struct DataResponse<T: Decodable>: Decodable {

  let kind: DataKind
  let data: T

}
