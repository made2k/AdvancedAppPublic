//
//  Reachability.swift
//  Reddit
//
//  Created by made2k on 7/17/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Alamofire
import RxCocoa
import RxSwift

class Reachability: NSObject {
  
  static let shared = Reachability()
  
  private let reachability: NetworkReachabilityManager = NetworkReachabilityManager().unsafelyUnwrapped
  
  private let statusRelay = BehaviorRelay<NetworkReachabilityManager.NetworkReachabilityStatus>(value: .unknown)
  var statusObserver: Observable<NetworkReachabilityManager.NetworkReachabilityStatus> {
    return statusRelay.asObservable()
  }
  
  var isReachable: Bool {
    return reachability.isReachable
  }
  
  var isReachableOnEthernetOrWiFi: Bool {
    return reachability.isReachableOnEthernetOrWiFi
  }
  
  var isReachableOnWiFi: Bool {
    return reachability.isReachableOnEthernetOrWiFi
  }
  
  var currentStatus: NetworkReachabilityManager.NetworkReachabilityStatus {
    return reachability.status
  }
  
  private override init() {
    super.init()
    startReachabilityObserver()
  }

  deinit {
    reachability.stopListening()
  }
  
  func configure() { }
  
  private func startReachabilityObserver() {
    reachability.startListening { [weak self] status in
      self?.statusRelay.accept(status)
    }
    
  }
}
