//
//  PostThumbnailContextMenu.swift
//  Reddit
//
//  Created by made2k on 8/10/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import SafariServices
import UIKit

private typealias ParsedViewControllers = (preview: UIViewController?, commit: UIViewController?)

class UrlPreviewContextMenu: ContextMenu {

  private var previewViewController: UIViewController?
  private var commitViewController: UIViewController?

  override var previewProvider: UIContextMenuContentPreviewProvider? {
    return { [weak self] in
      self?.previewViewController ?? self?.createControllersReturningPreview()
    }
  }

  private let model: LinkModel?
  private let mediaSize: CGSize?
  private let url: URL?
  
  // MARK: - Initialization
  
  init(linkModel: LinkModel) {
    self.model = linkModel
    self.mediaSize = nil
    self.url = linkModel.link.url
    
    super.init()
  }

  init(url: URL, mediaSize: CGSize?) {
    self.url = url
    self.mediaSize = mediaSize
    self.model = nil
    
    super.init()
  }
  
  // MARK: - Preview Parsing
  
  private func createControllersReturningPreview() -> UIViewController? {
    guard let url = url else { return nil }
    
    let parsedControllers: ParsedViewControllers
    
    if let model = model {
      parsedControllers = parseLink(model, linkUrl: url)
    } else {
      parsedControllers = parseUrl(url, contentSize: mediaSize)
    }
    
    commitViewController = parsedControllers.commit
    previewViewController = parsedControllers.preview

    return parsedControllers.preview
  }
  
  private func parseUrl(_ url: URL, contentSize: CGSize?) -> ParsedViewControllers {
    self.createViewControllers(sourceUrl: url, previewUrl: nil, expectedSize: contentSize)
  }
  
  private func parseLink(_ model: LinkModel, linkUrl: URL) -> ParsedViewControllers {
    
    let link = model.link
    
    // We have a reddit video, this would evaluate to a SFSafariViewController, but we want to
    // preview in app instead
    if let media = link.media, media.isGif == false {
      let navigation = NavigationController()
      let coordinator = LinkCoordinator(model: model, navigation: navigation)
      coordinator.start()

      return (navigation, navigation)
    }
    
    var mediaUrl: URL?
    var expectedSize = link.preview?.sourceSize
    
    // If we have a gif, that can be used to show as normal media
    if let media = link.media, media.isGif {
      mediaUrl = media.fallbackUrl
      expectedSize = CGSize(width: media.width, height: media.height)
      
    } else if let preview = link.preview?.mp4 ?? link.preview?.images.first {
      mediaUrl = preview.source.url
    }
    
    // If our link type is not media, we don't want to preview media
    let previewingUrl = model.linkType == .image ? mediaUrl : nil
    return createViewControllers(sourceUrl: linkUrl, previewUrl: previewingUrl, expectedSize: expectedSize)
  }
  
  // MARK: - View Controller Loading
  
  private func createViewControllers(sourceUrl: URL, previewUrl: URL?, expectedSize: CGSize?) -> ParsedViewControllers {
    
    var previewController: UIViewController?
    var commitController: UIViewController?
    
    previewController = LinkHandler.viewController(for: sourceUrl, previewing: true)
    
    // If our preview ended up being a safari controller, try again with preview url
    if let previewUrl = previewUrl, previewController is SFSafariViewController {
      previewController = LinkHandler.viewController(for: previewUrl, previewing: true)
    }

    /*
     If we're previewing into a link controller, or if we would be previewing a Safari
     controller, AND we have a link model. We should just preview and commit
     into the link controller.
     */
    if
      let linkModel = model,
      previewController?.topViewController() is LinkViewController || previewController is SFSafariViewController {
      
      let coordinator = LinkCoordinator(model: linkModel, navigation: nil)
      coordinator.start()
      previewController = coordinator.navigation
      commitController = previewController
      return (previewController, commitController)
    }

    if let linkModel = model {
      let coordinator = LinkCoordinator(model: linkModel, navigation: nil)
      coordinator.start()
      commitController = coordinator.controller

    } else {
      commitController = LinkHandler.viewController(for: sourceUrl, previewing: false)

      /*
       If we have a preview url, and we parsed the commit controller as a safari controller,
       and the source URL comes from reddit, we're safe using the preview.
       This happens for a url like: https://i.redd.it/ktc1ekioqtl31.gif
       */
      if
        let previewUrl = previewUrl,
        commitController is SFSafariViewController && sourceUrl.isRedditMedia() {
        commitController = LinkHandler.viewController(for: previewUrl, previewing: false)
      }
    }

    if
      let mediaController = previewController as? BaseMediaViewController,
      let contentSize = expectedSize,
      let windowSize = UIApplication.shared.activeWindow()?.size {

      mediaController.preferredContentSize = contentSize.aspectFit(to: windowSize)
    }

    if
      let preview = previewController,
      let commit = commitController,
      type(of: preview) == type(of: commit) {
        commitController = previewController
    }

    return (previewController, commitController)
  }

  // MARK: - Context Menu Extension
  
  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
    guard let commit = commitViewController else { return }
    
    switch UIViewController.displayStyle(for: commit) {
    case .modal:
      animator.preferredCommitStyle = .pop
    case .primary, .detail, .none:
      if SplitCoordinator.current.splitViewController.traitCollection.horizontalSizeClass == .compact {
        animator.preferredCommitStyle = .pop
      } else {
        animator.preferredCommitStyle = .dismiss
      }
    }
    
    animator.addCompletion {
      SplitCoordinator.current.splitViewController.display(commit)
    }
  }
  
  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
    previewViewController = nil
    commitViewController = nil
  }

}
