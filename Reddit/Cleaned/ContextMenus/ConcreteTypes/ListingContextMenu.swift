//
//  ListingContextMenu.swift
//  Reddit
//
//  Created by made2k on 8/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import SFSafeSymbols
import UIKit

/**
 This context menu shows a preview of the URL listing and also proved menu
 options for common actions. Things like `save`, `hide`...
 */
final class ListingContextMenu: UrlPreviewContextMenu {

  private let model: LinkModel
  private weak var sourceView: UIView?
  private weak var delegate: ListingsCellDelegate?

  override var actionProvider: UIContextMenuActionProvider? {
    guard #available(iOS 13.0, *) else { return nil }
    return { [weak self] _ in self?.createMenu() }
  }
  
  private var isSignedIn: Bool {
    return AccountModel.currentAccount.value.isSignedIn
  }
  
  // MARK: - Initialization

  
  /// Create this context menu with the provided parameters.
  /// - Parameter model: The link model for actions to take place on and the preview to be generated.
  /// - Parameter sourceView: An optional view that will be used for the highlight and dismiss animation.
  /// - Parameter delegate: The delegate to handle the callbacks.
  init?(model: LinkModel, sourceView: UIView?, delegate: ListingsCellDelegate) {
    self.model = model
    self.sourceView = sourceView
    self.delegate = delegate
    
    super.init(linkModel: model)
  }
  
  // MARK: - Context Menu Extension
  
  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    guard let sourceView = sourceView else { return nil }
    return UITargetedPreview(view: sourceView)
  }
  
  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    guard let sourceView = sourceView else { return nil }
    return UITargetedPreview(view: sourceView)
  }
  
  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
    if Settings.previewingMarksPostAsRead.value {
      model.markRead()
    }
  }
  
  // MARK: - Menu Creation
  
  @available(iOS 13.0, *)
  private func createMenu() -> UIMenu {
    let children: [UIMenuElement] = [
      userAction(),
      hideAction(),
      saveAction(),
      copyPostUrl(),
      markAboveAsReadAction(),
      filterMenu(),
      editMenu()].compactMap { $0 }
    
    let menu = UIMenu(title: "", children: children)
    return menu
  }
  
  @available(iOS 13.0, *)
  private func userAction() -> UIMenuElement {
    let author = model.link.author
    let action = UIAction(title: "/u/\(author)", image: UIImage(systemSymbol: .personCropCircle)) { [unowned self] _ in
      self.delegate?.listingCellDidOpenUser(author)
    }
    return action
  }
  
  @available(iOS 13.0, *)
  private func hideAction() -> UIMenuElement? {
    guard isSignedIn else { return nil }
    
    let currentHiddenState = model.hidden.value
    let title = currentHiddenState ? R.string.listings.unhidePostTitle() : R.string.listings.hidePostTitle()
    let icon = currentHiddenState ? UIImage(systemSymbol: .eye) : UIImage(systemSymbol: .eyeSlash)
    
    let action = UIAction(title: title, image: icon) { [unowned self] _ in
      self.delegate?.listingCellToggledHidden(for: self.model)
    }
    
    return action
  }
  
  @available(iOS 13.0, *)
  private func saveAction() -> UIMenuElement? {
    guard isSignedIn else { return nil }
    
    let currentSavedState = model.saved.value
    let title = currentSavedState ? R.string.listings.unsavePostTitle() : R.string.listings.savePostTitle()
    let icon = currentSavedState ? UIImage(systemSymbol: .bookmarkFill) : UIImage(systemSymbol: .bookmark)
    
    let action = UIAction(title: title, image: icon) { [unowned self] _ in
      self.delegate?.listingCellToggledSave(for: self.model)
    }
    
    return action
  }
  
  @available(iOS 13.0, *)
  private func copyPostUrl() -> UIMenuElement? {
    guard let permalink = model.link.permalink else { return nil }
    
    let title: String = R.string.listings.copy()
    let icon: UIImage = UIImage(systemSymbol: .docOnDoc)
    
    let action = UIAction(title: title, image: icon) { [unowned self] _ in
      self.delegate?.listingCellDidCopyLinkUrl(url: permalink)
    }
    
    return action
  }
  
  @available(iOS 13.0, *)
  private func editMenu() -> UIMenuElement? {
    guard isSignedIn else { return nil }
    guard model.isUsersPost else { return nil }
    guard model.link.archived == false else { return nil }
    
    guard let deleteAction = deleteAction() else { return nil }
    
    let menu = UIMenu(title: "", options: [.displayInline], children: [deleteAction])
    return menu
  }
  
  @available(iOS 13.0, *)
  private func deleteAction() -> UIMenuElement? {
    guard isSignedIn else { return nil }
    guard model.isUsersPost else { return nil }
    guard model.link.archived == false else { return nil }
    
    let confirmDelete = UIAction(title: R.string.listings.deleteActionTitle(), image: UIImage(systemSymbol: .trash), attributes: .destructive) { [unowned self] _ in
      self.delegate?.listingCellDidDelete(model: self.model)
    }
    
    let cancelDelete = UIAction(title: R.string.listings.cancelDeleteTitle(), image: UIImage(systemSymbol: .xmarkCircle), handler: { _ in })
    
    let menu = UIMenu(title: R.string.listings.deleteActionTitle(), image: UIImage(systemSymbol: .trash), options: [.destructive], children: [cancelDelete, confirmDelete])
    
    return menu
  }
  
  @available(iOS 13.0, *)
  private func markAboveAsReadAction() -> UIMenuElement? {
    guard delegate?.canMarkAboveAsRead(for: model) == true else { return nil }
    
    let action = UIAction(title: R.string.link.markAboveAsRead(), image: UIImage(systemSymbol: .eyeFill)) { [unowned self] _ in
      self.delegate?.listingCellMarkedRead(above: self.model)
    }
    return action
  }
  
  @available(iOS 13.0, *)
  private func filterMenu() -> UIMenuElement {
    
    let availableSubtypes: [FilterSubtype] = [
      .subreddit,
      .author,
      .subject,
      .domain,
      .flair,
      .score,
      .commentCount
    ]
    
    var children: [UIAction] = []
    
    for subType in availableSubtypes {
      
      let action = UIAction(title: subType.description) { [unowned self] _ in
        self.delegate?.listingCellDidFilter(model: self.model, subtype: subType)
      }
      children.append(action)
    }
    
    let menu = UIMenu(title: "Filter this", image: UIImage(systemSymbol: .chevronRight), children: children)

    return menu
  }

}
