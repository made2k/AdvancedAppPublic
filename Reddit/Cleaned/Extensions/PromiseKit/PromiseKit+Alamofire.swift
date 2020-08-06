//
//  PromiseKit+Alamofire.swift
//  Reddit
//
//  Created by made2k on 4/4/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Alamofire
import PromiseKit

extension Alamofire.DataRequest {

  func responseString(queue: DispatchQueue = .main) -> Promise<(string: String, response: PMKAlamofireDataResponse)> {

    Promise { seal in

      responseString(queue: queue) { response in

        switch response.result {
        case .success(let value):
          seal.fulfill((value, PMKAlamofireDataResponse(response)))

        case .failure(let error):
          seal.reject(error)

        }

      }

    }

  }

  func responseData(queue: DispatchQueue = .main) -> Promise<(data: Data, response: PMKAlamofireDataResponse)> {

    Promise { seal in

      responseData(queue: queue) { response in

        switch response.result {
        case .success(let value):
          seal.fulfill((value, PMKAlamofireDataResponse(response)))

        case .failure(let error):
          seal.reject(error)
        }
        
      }
    }

  }

}

/// Alamofire.DataResponse, but without the `result`, since the Promise represents the `Result`
struct PMKAlamofireDataResponse {

  public init<T>(_ rawrsp: Alamofire.DataResponse<T, AFError>) {
    request = rawrsp.request
    response = rawrsp.response
    data = rawrsp.data
  }

  /// The URL request sent to the server.
  public let request: URLRequest?

  /// The server's response to the URL request.
  public let response: HTTPURLResponse?

  /// The data returned by the server.
  public let data: Data?
}
