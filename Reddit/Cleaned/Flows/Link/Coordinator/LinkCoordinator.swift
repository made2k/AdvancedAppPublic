//
//  LinkCoordinator.swift
//  Reddit
//
//  Created by made2k on 1/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RxCocoa
import UIKit

final class LinkCoordinator: NSObject, Coordinator {

  private(set) weak var navigation: UINavigationController!
  private(set) var model: LinkModel? {
    didSet {
      controller?.title = model?.link.subreddit
      
      guard let model = model else { return }
      // Load info for the right side bar
      SubredditCache.shared.loadIfNeeded(model.link.subreddit)
      if let focusing = focusingId.value {
        controller?.scrollToCommentId(focusing)
      }
    }
  }
  /// Indicates no link will be loaded from this coordinator
  private let isEmpty: Bool

  private(set) weak var controller: LinkViewController?

  var childCoordinator: Coordinator?

  var videoDisposable: VideoDisposable?
  let focusingId = BehaviorRelay<String?>(value: nil)
  var contentLoadEncounteredError = false

  init(model: LinkModel, navigation: UINavigationController?) {
    self.navigation = navigation
    self.isEmpty = false

    super.init()

    defer {
      self.model = model
    }
  }

  init(linkMatch: SubredditLinkMatch, navigation: UINavigationController?) {
    self.navigation = navigation
    self.isEmpty = false

    super.init()

    loadIntoSubreddit(match: linkMatch)
  }

  init(navigation: UINavigationController) {
    self.navigation = navigation
    self.isEmpty = true
  }

  func start() {

    let navigation = self.navigation ?? NavigationController()
    self.navigation = navigation

    let controller = LinkViewController(model: model, modelWouldBeLoading: isEmpty == false, delegate: self)
    controller.navigationItem.largeTitleDisplayMode = .never
    controller.title = model?.link.subreddit
    self.controller = controller
    if let focusing = focusingId.value {
      controller.scrollToCommentId(focusing)
    }

    let needsAnimation = navigation.viewControllers.isNotEmpty
    navigation.pushViewController(controller, animated: needsAnimation)

    // TODO: Fix if model isn't available yet
    model?.markRead()
  }

  private func loadIntoSubreddit(match: SubredditLinkMatch) {
    
    firstly {
      APIContainer.shared.session.loadLink(subredditName: match.subreddit,
                                           linkName: match.linkName,
                                           postTitle: match.postTitle,
                                           focusId: match.focusId,
                                           context: match.context)

    }.map { (link, comments) -> LinkModel in
      let treeModel = CommentTreeModel(tree: comments)
      let model = LinkModel(link, commentTree: treeModel)
      return model

    }.done { linkModel in
      self.model = linkModel
      self.controller?.model = linkModel
      self.controller?.reloadData()

      if let focusing = self.focusingId.value {
        self.controller?.scrollToCommentId(focusing)
      }

    }.catch { _ in
      self.controller?.errorMessage = "Failed to load post"
    }

  }

}
