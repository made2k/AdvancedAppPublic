//
//  SubredditButtonNode.swift
//  Reddit
//
//  Created by made2k on 2/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

final class SubredditButtonNode: ButtonNode {
  private let subredditName: String
  private let contextMenu: SubredditContextMenu
  private var disposeBag = DisposeBag()
  
  init(subreddit: String, weight: FontWeight = .regular, size: FontSize = .default, color: UIColor = .label) {
    subredditName = subreddit
    contextMenu = SubredditContextMenu(subredditName: subreddit)

    super.init(image: nil, text: "r/\(subreddit)", weight: weight, size: size, color: color)
  }
  
  override func didLoad() {
    super.didLoad()
    contextMenu.register(view: self.view)
  }

  override func didEnterPreloadState() {
    super.didEnterPreloadState()
    setupBindings()
  }

  override func didExitPreloadState() {
    super.didExitPreloadState()
    disposeBag = DisposeBag()
  }

  private func setupBindings() {

    rx.tap
      .map { [subredditName] () -> URL? in
        return URL(string: "https://www.reddit.com/r/\(subredditName)")
      }
      .filterNil()
      .subscribe(onNext: { (url: URL) in
        LinkHandler.handleUrl(url)

      }).disposed(by: disposeBag)

  }

}
