//
//  MoreModel.swift
//  Reddit
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI
import RxCocoa
import RxSwift

class MoreModel: CommentModelType {

  // CommentModelType
  private(set) lazy var id = UUID().uuidString
  private(set) lazy var name = UUID().uuidString
  private(set) weak var parent: CommentModelType?

  let children: [CommentModelType] = []
  let allChildren: [CommentModelType] = []

  let isUserComment: Bool = false
  
  let collapsed = BehaviorRelay<Bool>(value: false)
  var hidden: Bool { return parent?.collapsed.value == true || parent?.hidden == true }
  var level: Int {
    guard let parent = parent else { return 0 }
    return parent.level + 1
  }
  
  private(set) lazy var bodyHtmlObserver = Observable.just(bodyHtml)
  private(set) lazy var bodyHtml = body
  private(set) lazy var body = "Load \(childCount) more"

  // Properties

  let childrenIds: [String]
  var childCount: Int { return childrenIds.count }

  let object: More

  init(more: More, parent: CommentModel?) {
    self.object = more
    self.parent = parent
    childrenIds = more.childrenIds
  }

}
