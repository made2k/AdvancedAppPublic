//
//  CommonSubmitViewModel.swift
//  Reddit
//
//  Created by made2k on 1/29/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RxCocoa
import RxSwift

class CommonSubmitViewModel: NSObject {

  static let maxTitleLength: Int = 300
  static let maxBodyLength: Int = 4000

  let model: SubmitModel

  var maxTitleLength: Observable<String> {
    return model.title
      .replaceNilWith("")
      .map { (title: String) -> Int in
        return title.count

      }.map { (count: Int) -> String in
        return "\(count)/\(Self.maxTitleLength)"
      }
  }

  var title: BehaviorRelay<String?> {
    return model.title
  }

  var sendReplies: BehaviorRelay<Bool> {
    return model.sendReplies
  }

  var showRulesButton: Observable<Bool> {
    return Observable<Bool>.just(model.subredditRules != nil)
  }

  init(model: SubmitModel) {
    self.model = model
  }

  func canChangeTextForTitle(_ proposed: String) -> Bool {
    return proposed.count <= Self.maxTitleLength
  }

}
