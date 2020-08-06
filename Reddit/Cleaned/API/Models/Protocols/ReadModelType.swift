//
//  ReadModelType.swift
//  Reddit
//
//  Created by made2k on 9/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RxCocoa
import RxSwift

protocol ReadModelType: ViewModel {

  var readObserver: Observable<Bool> { get }
  var read: Bool { get }

  @discardableResult
  func markRead() -> Promise<Void>
  @discardableResult
  func markUnread() -> Promise<Void>

}
