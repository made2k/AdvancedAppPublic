//
//  UserCache.swift
//  Reddit
//
//  Created by made2k on 8/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RxSwift

class UserCache: NSObject {
  
  static let shared: UserCache = UserCache()
  private let disposeBag = DisposeBag()
  
  private var cache: [String: UserModel] = [:]
  
  private override init() {
    super.init()
    setupBindings()
  }
  
  private func setupBindings() {
    
    NotificationCenter.default.rx.notification(UIApplication.didReceiveMemoryWarningNotification)
      .subscribe(onNext: { [unowned self] _ in
        self.reset()
      }).disposed(by: disposeBag)
    
  }
  
  func lookup(_ username: String) -> UserModel? {
    return cache[username.lowercasedTrim]
  }
  
  func add(_ model: UserModel) {
    let path = model.username.lowercasedTrim
    cache[path] = model
  }
  
  func reset() {
    cache.removeAll()
  }
  
  func loadIfNeeded(_ username: String) -> Promise<UserModel> {
    if let cached = cache[username.lowercasedTrim] {
      return .value(cached)
    }
    
    return firstly {
      APIContainer.shared.session.getUserProfile(username: username)
      
    }.map {
      UserModel(user: $0)
      
    }.get {
      self.add($0)
    }
    
  }
  
}
