//
//  DataRequest+Promise.swift
//  Reddit
//
//  Created by made2k on 6/3/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Alamofire
import PromiseKit
import SwiftyJSON

extension DataRequest {

  func responseJsonObject(queue: DispatchQueue = .main) -> Promise<JSON> {

    return Promise<JSON> { seal in

      responseJSON(queue: queue) { response in

        switch response.result {

        case .success(let value):
          seal.fulfill(JSON(value))

        case .failure(let error):
          seal.reject(error)
        }

      }

    }

  }

}
