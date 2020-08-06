//
//  LinkSubmissionViewControllerDataSource.swift
//  Reddit
//
//  Created by made2k on 1/29/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RxCocoa
import RxSwift

protocol LinkSubmissionViewControllerDataSource {

  var maxTitleLength: Observable<String> { get }

  var title: BehaviorRelay<String?> { get }
  var link: BehaviorRelay<String?> { get }

  var sendReplies: BehaviorRelay<Bool> { get }

  var showRulesButton: Observable<Bool> { get }

  func canChangeTextForTitle(_ proposed: String) -> Bool

}
