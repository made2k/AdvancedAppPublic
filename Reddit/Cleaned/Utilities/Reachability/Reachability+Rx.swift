//
//  Reachability+Rx.swift
//  Reddit
//
//  Created by made2k on 2/18/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Alamofire
import RxSwift

extension Reactive where Base: Reachability {

  var reachabilityChanged: Observable<NetworkReachabilityManager.NetworkReachabilityStatus> {
    return base.statusObserver
  }

  var reachableOnWifi: Observable<Bool> {
    return reachabilityChanged
      .map { status -> Bool in

        switch status {
        case .reachable(.ethernetOrWiFi):
          return true
        default:
          return false
        }

    }
  }

}
