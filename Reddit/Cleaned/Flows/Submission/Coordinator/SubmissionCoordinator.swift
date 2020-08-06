//
//  SubmissionCoordinator.swift
//  Reddit
//
//  Created by made2k on 1/29/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RedditAPI
import UIKit

final class SubmissionCoordinator: NSObject, Coordinator {

  private let presenter: UIViewController
  let model: SubmitModel

  private(set) weak var navigation: UINavigationController?

  init(presenter: UIViewController, subreddit: Subreddit, autoSave: AutoSavedPost?) {
    self.presenter = presenter
    self.model = SubmitModel(subreddit: subreddit, autoSave: autoSave)
  }

  func start() {
    let controller: SubmitContainerViewController =
      SubmitContainerViewController.create(with: model, strongDelegate: self)

    let navigation: UINavigationController = NavigationController(controllers: controller)
    self.navigation = navigation

    presenter.present(navigation)
  }

}
