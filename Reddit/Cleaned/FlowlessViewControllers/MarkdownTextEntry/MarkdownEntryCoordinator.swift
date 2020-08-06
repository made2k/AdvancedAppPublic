//
//  MarkdownEntryCoordinator.swift
//  Reddit
//
//  Created by made2k on 1/30/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import UIKit

final class MarkdownEntryCoordinator: NSObject, Coordinator {

  private let presenter: UIViewController
  private weak var delegate: MarkdownEntryCoordinatorDelegate?

  private weak var navigation: UINavigationController?

  init(presenter: UIViewController, delegate: MarkdownEntryCoordinatorDelegate) {
    self.presenter = presenter
    self.delegate = delegate
  }

  func start() {
    guard let delegate = delegate else { return }

    let controller = MarkdownTextEntryViewController.create(with: delegate, strongDelegate: self)
    let navigation = NavigationController(controllers: controller)
    self.navigation = navigation

    presenter.present(navigation)
  }

}

extension MarkdownEntryCoordinator: MarkdownTextEntryNavigationDelegate {

  func didTapToDismiss() {
    navigation?.dismiss()
  }

  func didTapToSave(_ text: String) {
    delegate?.markdownTextEntryDidFinish(text)
    navigation?.dismiss()
  }

}
