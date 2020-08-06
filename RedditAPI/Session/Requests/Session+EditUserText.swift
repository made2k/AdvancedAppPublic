//
//  Session+EditUserText.swift
//  RedditAPI
//
//  Created by made2k on 6/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

extension Session {

  public func editUserText<T: EditableThing & Decodable>(thing: T, newText: String) -> Promise<EditableThing> {

    firstly {
      controller.request(.editUserText(thing, newText: newText))

    }.map { (response: JsonDataResponse<ThingsResponse<DataResponse<T>>>) -> T in
      guard let value = response.data.things.first?.data else {
        throw APIError.badResponse
      }
      return value
    }

  }

}
