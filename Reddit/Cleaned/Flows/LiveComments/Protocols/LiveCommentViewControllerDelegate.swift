//
//  LiveCommentViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 2/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit
import RxCocoa
import RxSwift

protocol LiveCommentViewControllerDelegate: class, ASTableDataSource, ASTableDelegate {

  var replyText: Observable<String> { get }
  var idleTimerRelay: BehaviorRelay<Bool> { get }
  var idleButtonTitle: Observable<String> { get }

  func didReply(with text: String) -> Promise<Void>

  func didDismiss()

}
