//
//  SideMenuCoordinator.swift
//  Reddit
//
//  Created by made2k on 2/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RxSwift
import SideMenu
import UIKit

class SideMenuCoordinator: NSObject, Coordinator {

  private let window: UIWindow

  private var hasStarted: Bool = false
  private let manager = SideMenuManager.default
  private let disposeBag = DisposeBag()

  lazy var sideNavigation: SideNavigationController = .init(rootViewController: controller)
  private lazy var controller: SideMenuViewController = .init(delegate: self)

  init(window: UIWindow) {
    self.window = window

    super.init()

    setupBindings()
  }

  func start() {
    guard hasStarted == false else { return }
    hasStarted = true

    let presentationStyle = SideMenuPresentationStyle.menuSlideIn
    presentationStyle.presentingEndAlpha = 0.65

    sideNavigation.presentationStyle = presentationStyle
    manager.rightMenuNavigationController = sideNavigation
  }

  private func setupBindings() {

    window.rx.observe(CGRect.self, "frame")
      .filterNil()
      .map { $0.size }
      .map { min($0.width - 75, 350) }
      .bind(to: manager.rx.menuWidth)
      .disposed(by: disposeBag)

  }


}
