//
//  VoteButtonNode.swift
//  Reddit
//
//  Created by made2k on 10/30/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit
import Haptica
import RedditAPI
import RxSwift

class VoteButtonNode: ButtonNode {

  private let model: VoteModelType
  private let direction: VoteDirection
  private let defaultColor: UIColor

  private var activeBackgroundColor: UIColor {
    switch direction {
    case .up: return UIColor.upvote
    case .down: return UIColor.downvote
    case .none: return UIColor.clear
    }
  }

  var insets: CGFloat = 4 {
    didSet { insetPadding = UIEdgeInsets(inset: insets) }
  }

  private var disposeBag = DisposeBag()
  
  init(model: VoteModelType, direction: VoteDirection, defaultColor: UIColor) {
    self.model = model
    self.direction = direction
    self.defaultColor = defaultColor
    
    super.init()

    contentMode = .scaleAspectFit

    style.minWidth = ASDimensionMake(15)
    style.minHeight = ASDimensionMake(15)
    cornerRadius = 5
    insetPadding = UIEdgeInsets(inset: insets)
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

    let isSelected = model.voteDirectionRelay
      .map { [unowned self] in $0 == self.direction }
      .share(replay: 1)

    isSelected
      .map { [unowned self] in $0 ? self.activeBackgroundColor : UIColor.clear }
      .bind(to: rx.backgroundColor)
      .disposed(by: disposeBag)

    isSelected
      .map { [unowned self] (selected: Bool) -> UIColor in
        selected ?
          .systemBackground :
          self.defaultColor
      }
      .bind(to: rx.tintColor)
      .disposed(by: disposeBag)

    rx.tap
      .subscribe(onNext: { [weak self] in
        self?.buttonPressed()
      }).disposed(by: disposeBag)

  }
  
  private func buttonPressed() {
    guard AccountModel.currentAccount.value.isSignedIn else {
      SplitCoordinator.current.splitViewController.showSignInError()
      return
    }
    Haptic.impact(.light).generate()

    switch direction {
    case .up: model.upVote().cauterize()
    case .down: model.downVote().cauterize()
    case .none: break
    }

  }
  
  private func handleError(_ error: Error) {
    if case APIError.notSignedIn = error {
      closestViewController?.showSignInError()
      return
    }

    Toast.show("A problem occurred", duration: 2)
  }
    
  func setSize(_ size: CGFloat) {
    bounds = CGRect(x: 0, y: 0, width: size, height: size)
    style.preferredSize = CGSize(square: size)
  }
  
}

class UpvoteButtonNode: VoteButtonNode {
  
  init(model: VoteModelType, defaultColor: UIColor) {
    super.init(model: model, direction: .up, defaultColor: defaultColor)
    image = R.image.icon_upvote()
  }
}

class DownvoteButtonNode: VoteButtonNode {
  
  init(model: VoteModelType, defaultColor: UIColor) {
    super.init(model: model, direction: .down, defaultColor: defaultColor)
    image = R.image.icon_downvote()
  }
}
