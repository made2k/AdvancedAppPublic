//
//  CommentContextMenu.swift
//  Reddit
//
//  Created by made2k on 8/15/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import SFSafeSymbols
import UIKit

final class CommentContextMenu: ContextMenu {
  
  private let model: CommentModel
  private weak var sourceView: UIView?
  private weak var delegate: CommentContextMenuDelegate?
  
  override var actionProvider: UIContextMenuActionProvider? {
    guard #available(iOS 13.0, *) else { return nil }
    return { [weak self] _ in self?.createMenu() }
  }
  
  private var userIsSignedIn: Bool {
    return AccountModel.currentAccount.value.isSignedIn
  }
  
  init(model: CommentModel, sourceView: UIView, delegate: CommentContextMenuDelegate) {
    self.model = model
    self.delegate = delegate
    self.sourceView = sourceView
  }

  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                              willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                              animator: UIContextMenuInteractionCommitAnimating) {
    animator.preferredCommitStyle = .dismiss
  }
  
  // MARK: - Menu
  
  @available(iOS 13.0, *)
  private func createMenu() -> UIMenu {
    let items: [UIMenuElement] = [
      editAction(model),
      shareAction(model),
      replyAction(model),
      textSelectionAction(model),
      remindAction(model),
      userAction(model),
      filterAction(model),
      deleteAction(model)
      ].compactMap { $0 }
    
    return UIMenu(title: "", children: items)
  }
  
  @available(iOS 13.0, *)
  private func editAction(_ model: CommentModel) -> UIAction? {
    guard model.isUserComment && model.archived == false else { return nil }
    
    let action = UIAction(
      title: R.string.commentContext.editTitle(),
      image: UIImage(systemSymbol: .squareAndPencil)) { [weak self] _ in
        self?.delegate?.commentContextDidEdit(model: model)
    }
    
    return action
  }
  
  @available(iOS 13.0, *)
  private func shareAction(_ model: CommentModel) -> UIAction? {
    guard let sourceView = sourceView else { return nil }
    
    let action = UIAction(
      title: R.string.commentContext.shareTitle(),
      image: UIImage(systemSymbol: .squareAndArrowUp)) { [weak self] _ in
        self?.delegate?.commentContextDidShare(model: model, sourceView: sourceView)
    }
    
    return action
  }
  
  @available(iOS 13.0, *)
  private func replyAction(_ model: CommentModel) -> UIAction? {
    guard model.archived == false else { return nil }
    guard userIsSignedIn else { return nil }
    
    let action = UIAction(
      title: R.string.commentContext.replyTitle(),
      image: UIImage(systemSymbol: .arrowshapeTurnUpLeft)) { [weak self] _ in
        self?.delegate?.commentContextDidReply(model: model)
    }
    
    return action
  }

  @available(iOS 13.0, *)
  private func textSelectionAction(_ model: CommentModel) -> UIAction {
    let action = UIAction(
      title: R.string.commentContext.selectTextTitle(),
      image: UIImage(systemSymbol: .textCursor)) { [weak self] _ in
        self?.delegate?.commentContextDidSelectText(model: model)
    }
    
    return action
  }
  
  @available(iOS 13.0, *)
  private func remindAction(_ model: CommentModel) -> UIAction {
    let url = model.comment.permaLink
    let body = model.body
    
    let action = UIAction(
      title: R.string.commentContext.remindTitle(),
      image: UIImage(systemSymbol: .clock)) { _ in
        ReminderTimeViewController.showReminder(type: .comment, url: url, body: body)
    }
    
    return action
  }
  
  @available(iOS 13.0, *)
  private func userAction(_ model: CommentModel) -> UIAction? {
    guard model.isDeleted == false else { return nil }
    
    let action = UIAction(
      title: R.string.commentContext.userTitle(model.author),
      image: UIImage(systemSymbol: .personCropCircle)) { [weak self] _ in
        self?.delegate?.commentContextDidOpenUser(model: model)
    }
    
    return action
  }
  
  @available(iOS 13.0, *)
  private func deleteAction(_ model: CommentModel) -> UIMenuElement? {
    guard model.isUserComment else { return nil }
    guard model.archived == false else { return nil }
    
    let confirmDelete = UIAction(title: R.string.listings.deleteActionTitle(), image: UIImage(systemSymbol: .trash), attributes: .destructive) { [unowned self] _ in
      self.delegate?.commentContextDidDelete(model: model)
    }
    
    let cancelDelete = UIAction(title: R.string.listings.cancelDeleteTitle(), image: UIImage(systemSymbol: .xmarkCircle), handler: { _ in })
    
    let menu = UIMenu(title: R.string.listings.deleteActionTitle(), image: UIImage(systemSymbol: .trash), options: [.destructive], children: [cancelDelete, confirmDelete])
    
    return menu
  }
  
  @available(iOS 13.0, *)
  private func filterAction(_ model: CommentModel) -> UIMenu {
    
    let filterOptions = [FilterSubtype.author, .subject, .score]
    
    var subActions: [UIMenuElement] = []
    
    for option in filterOptions {

      let action = UIAction(title: option.description) { [weak self] _ in
        self?.delegate?.commentContextDidFilter(model: model, subType: option)
      }
      subActions.append(action)
      
    }
    
    let menu = UIMenu(title: R.string.commentContext.filterTitle(),
                      image: UIImage(systemSymbol: .chevronRight),
                      children: subActions)
    return menu
  }

}
