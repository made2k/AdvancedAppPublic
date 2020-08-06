//
//  CommentModelType.swift
//  Reddit
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxCocoa
import RxSwift

protocol CommentModelType: class {

  var id: String { get }
  var name: String { get }
  var parent: CommentModelType? { get }

  var children: [CommentModelType] { get }
  var allChildren: [CommentModelType] { get }

  /// Indicates this comment was made by the signed in user
  var isUserComment: Bool { get }
  
  var collapsed: BehaviorRelay<Bool> { get }
  var hidden: Bool { get }
  var level: Int { get }
  
  var bodyHtmlObserver: Observable<String> { get }
  var bodyHtml: String { get }
  var body: String { get }
}
