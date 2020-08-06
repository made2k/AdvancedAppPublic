//
//  LiveCommentsCoordinator.swift
//  Reddit
//
//  Created by made2k on 2/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxASDataSources
import RxCocoa
import RxSwift
import UIKit

class LiveCommentsCoordinator: NSObject, Coordinator {

  private let presenting: UIViewController
  private(set) var model: LiveCommentModel!

  private(set) var navigation: NavigationController?
  private(set) var controller: LiveModeViewController?

  let replyingComment = BehaviorRelay<CommentModel?>(value: nil)
  private let disposeBag = DisposeBag()
  private var tableBag = DisposeBag()

  init(presenting: UIViewController, linkModel: LinkModel) {
    self.presenting = presenting
    self.model = LiveCommentModel(link: linkModel.link)

    super.init()

    self.model.delegate = self

    setupBindings()
  }

  func start() {

    let controller = LiveModeViewController(delegate: self)
    self.controller = controller

    let navigation = BaseLevelNavigation(controllers: controller)
    
    // TODO: Fix the dismissal on iOS 13
    // Issue is the draw upward when table is inversed, causes bounce
    if #available(iOS 13.0, *), AccountModel.currentAccount.value.isSignedIn {
      navigation.modalPresentationStyle = .fullScreen

    } else {
      navigation.modalPresentationStyle = .formSheet
    }
    
    self.navigation = navigation

    model.startLoading()
    presenting.present(navigation)
  }

  private func setupBindings() {

    idleTimerRelay
      .bind(to: UIApplication.shared.rx.isIdleTimerDisabled)
      .disposed(by: disposeBag)

  }

}

private class BaseLevelNavigation: NavigationController {

  override func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
    if #available(iOS 13.0, *) {
      return UITraitCollection(userInterfaceLevel: .base)
    }

    return super.overrideTraitCollection(forChild: childViewController)
  }

}
