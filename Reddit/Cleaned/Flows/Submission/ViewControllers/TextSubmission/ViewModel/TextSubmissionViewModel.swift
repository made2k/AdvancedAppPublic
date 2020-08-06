//
//  LinkSubmissionViewModel.swift
//  Reddit
//
//  Created by made2k on 1/29/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RxCocoa
import RxSwift

final class TextSubmissionViewModel: CommonSubmitViewModel, TextSubmissionViewControllerDataSource {

  private var autoSaveCounter: Int = 0

  var body: BehaviorRelay<String?> {
    return model.selfText
  }

  func bodyProgressChanged(_ newText: String?) {

    guard let text = newText else {
      AutoSaveManager.shared.clear()
      return
    }

    if autoSaveCounter % 10 == 0 {

      let subreddit: String = model.subreddit.displayName
      let title: String = self.title.value ?? ""
      let body: String = text

      AutoSaveManager.shared.savePost(
        subreddit: subreddit,
        title: title,
        text: body)
    }

    autoSaveCounter += 1
  }

}
