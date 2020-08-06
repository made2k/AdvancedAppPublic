//
//  LinkCoordinator+ASTableDataSource.swift
//  Reddit
//
//  Created by made2k on 1/13/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Logging
import PromiseKit
import RedditAPI

extension LinkCoordinator {

  // MARK: - Helper properties

  private var forceShowArticle: Bool {
    guard let model = model else { return true }

    let isExternalVideo = model.linkType == .video &&
      VideoExtractor.providerType(link: model.link) == .youtube &&
      OpenInPreference.shared.youtubePreference == .youtube

    return contentLoadEncounteredError || isExternalVideo
  }

  /**
   Title is displayed first not inline media
 */
  private var isTitleFirst: Bool {
    guard let model = model else {
      log.warn("Attempting to do table things without a model")
      return false
    }

    let linkType = model.linkType
    return linkType == .article || linkType == .selfText || linkType == .unknown || forceShowArticle
  }

  // MARK: - Row computed properties

  private var titleRow: Int {
    return isTitleFirst ? 0 : 1
  }

  // MARK: - ASTableDataSource

  func numberOfSections(in tableNode: ASTableNode) -> Int {
    // We have the content section, and the comments section
    return 2
  }

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    guard let model = model else {
      log.warn("Link Coordinator attempting to display table without a model")
      return 0
    }

    if section == 0 {
      // This section contains, title, content, vote bar
      return 3
    }

    let commentCount = model.commentTree?.allComments.count ?? 0
    return max(commentCount, 1)
  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    guard let model = model else { fatalError("Attempted to load cell block without a model") }

    switch indexPath.section {

    case 0:
      return contentSectionBlock(for: indexPath, model: model)

    case 1:
      return commentSectionBlock(for: indexPath, model: model)

    default:
      fatalError("unexpected indexPath")

    }

  }

  // MARK: - Content Block Helpers

  private func contentSectionBlock(for indexPath: IndexPath, model: LinkModel) -> ASCellNodeBlock {

    assert(indexPath.section == 0, "Wrong block for indexPath")

    switch indexPath.row {

    case 0:
      if isTitleFirst {
        return titleBlock(model: model)
      }
      return model.linkType == .image ? imageBlock(model: model) : videoBlock(model: model)

    case 1:
      if isTitleFirst == false { return titleBlock(model: model) }

      if model.linkType == .article || forceShowArticle {
        return articleBlock(model: model)
      }

      return selfTextBlock(model: model)

    case 2:
      return voteActionBlock(model: model)

    default:
      fatalError("unexpected index path")

    }

  }

  private func titleBlock(model: LinkModel) -> ASCellNodeBlock {
    return {
      TitleCellNode(linkModel: model)
    }
  }

  private func imageBlock(model: LinkModel) -> ASCellNodeBlock {
    return {
      let node = LinkContentImageCellNode(linkModel: model)
      node.hidingNSFW = false
      return node
    }
  }

  private func videoBlock(model: LinkModel) -> ASCellNodeBlock {
    return { [weak self] in

      let node = LinkContentVideoCell(link: model.link) { [weak self] in
        self?.contentLoadEncounteredError = true
        self?.controller?.reloadSections([0], with: .automatic)
      }
      self?.videoDisposable = node

      return node
    }
  }

  private func articleBlock(model: LinkModel) -> ASCellNodeBlock {
    return {
      LinkContentArticleCellNode(linkModel: model)
    }
  }

  private func voteActionBlock(model: LinkModel) -> ASCellNodeBlock {

    let observable = focusingId.asObservable()

    return {
      let node = LinkContentVoteCellNode(link: model, focusingObserver: observable)


      node.loadAllComments = { [unowned self] in
        self.doClear()
      }

      node.moreActions = { [unowned self] sender in
        self.showPostActions(sender: sender.view)
      }
      return node
    }
  }

  private func selfTextBlock(model: LinkModel) -> ASCellNodeBlock {
    let selfRef = self
    
    return {
      let node = LinkContentSelfTextCell(linkModel: model, delegate: selfRef)
      node.textDelegate = selfRef
      return node
    }

  }

  // MARK: - Comment Section Helpers

  private func commentSectionBlock(for indexPath: IndexPath, model: LinkModel) -> ASCellNodeBlock {

    if let comment = model.commentTree?.allComments[safe: indexPath.row] {
      return commentBlock(comment, linkModel: model, indexPath: indexPath)
    }

    if model.commentTree == nil {
      return loadingBlock()
    }

    return emptyBlock()

  }

  private func commentBlock(_ comment: CommentModelType, linkModel: LinkModel, indexPath: IndexPath) -> ASCellNodeBlock {

    let focusingId = self.focusingId

    if let commentModel = comment as? CommentModel {
      observeCommentCollapsedState(commentModel)
    }

    return { [weak self] in

      let node = CommentCellFactory.cell(for: comment, link: linkModel.link, delegate: self)
      node.isFocused = focusingId.value == comment.id
      node.textDelegate = self
      
      guard let comment = comment as? CommentModel else { return node }

      weak var weakNode = node

      node.longPressed = {
        guard let strongWeakNode = weakNode else { return }
        self?.showCommentActions(model: comment, sender: strongWeakNode.view)
      }

      node.replyAction = {
        self?.showCommentReply(comment)
      }

      return node
    }

  }

  func showCommentReply(_ comment: CommentModel) {
    guard AccountModel.currentAccount.value.isSignedIn else {
      self.controller?.showSignInError()
      return
    }

    let coordinator = CommentCreateCoordinator(presenting: navigation,
                                               replyName: comment.name,
                                               replyHtml: comment.bodyHtml,
                                               delegate: self)
    childCoordinator = coordinator

    coordinator.start()
  }

  private func loadingBlock() -> ASCellNodeBlock {
    return {
      LoadingActivityCellNode()
    }
  }

  private func emptyBlock() -> ASCellNodeBlock {
    return {
      CommentEmptyCellNode()
    }
  }

}

// MARK: - Helpers

private extension LinkCoordinator {

  private func doClear() {

    Overlay.shared.showProcessingOverlay()

    firstly {
      clearFocus()

    }.ensure {
      Overlay.shared.hideProcessingOverlay()

    }.cauterize()

  }

}
