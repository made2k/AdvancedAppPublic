//
//  SubredditContextMenu.swift
//  Reddit
//
//  Created by made2k on 8/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import SFSafeSymbols
import UIKit

class SubredditContextMenu: ContextMenu {
  
  private let subredditName: String
  private var listingRef: UIViewController?
  private var userIsSignedIn: Bool {
    return AccountModel.currentAccount.value.isSignedIn
  }
  
  override var previewProvider: UIContextMenuContentPreviewProvider? {
    let currentSubreddit = SplitCoordinator.current.visibleListingController?.subredditName
    guard currentSubreddit?.lowercasedTrim != subredditName.lowercasedTrim else { return nil }
    
    return { [weak self] in self?.getPreview() }
  }
  override var actionProvider: UIContextMenuActionProvider? {
    guard #available(iOS 13.0, *) else { return nil }
    return { [weak self] _ in self?.createMenu() }
  }
  
  init(subredditName: String) {
    self.subredditName = subredditName
  }
  
  // MARK: - Preview Controller
  
  private func getPreview() -> UIViewController? {
    let delegate: ListingsCoordinatorDelegate = SplitCoordinator.current
    let coordinator = ListingsCoordinator(navigation: nil,
                                          delegate: delegate,
                                          subredditName: subredditName)
    coordinator.start()
    let controller = coordinator.navigation
    listingRef = controller
    
    return controller
  }
  
  // MARK: - Menu
  
  @available(iOS 13.0, *)
  private func createMenu() -> UIMenu {
    let items: [UIMenuElement] = [
      subscribeAction(),
      sideBarAction()
      ].compactMap { $0 }
    
    return UIMenu(title: "", children: items)
  }
  
  @available(iOS 13.0, *)
  private func subscribeAction() -> UIMenuElement? {
    guard userIsSignedIn else { return nil }
    
    let isSubscribed: Bool
    
    let storedModel = SubredditCache.shared.lookupModel(subredditName)
    if let model = storedModel {
      isSubscribed = model.subscribed
      
    } else if AccountModel.currentAccount.value.hasFetchedSubscribedSubreddits {
      // Here we've fetched our subreddits, and it's not in the list, therefore
      // it can be assumed we're not subscribed.
      isSubscribed = false
      
    } else {
      // We don't know if user is subscribed or not, don't continue
      return nil
    }
        
    let title = isSubscribed ?
      R.string.subredditContext.unsubscribeTitle() :
      R.string.subredditContext.subscribeTitle()
    let image = isSubscribed ?
      UIImage(systemSymbol: .minusCircle) :
      UIImage(systemSymbol: .plusCircle)
    
    let loadModelPromise: Promise<SubredditModel>
    if let model = storedModel {
      loadModelPromise = .value(model)
      
    } else {
      loadModelPromise = SubredditModel.verifySubredditExists(path: subredditName)
    }
    
    let action = UIAction(title: title, image: image) { _ in
            
      firstly {
        loadModelPromise
        
      }.then { model -> Promise<Void> in
        return isSubscribed ?
          model.unsubscribe() :
          model.subscribe()
        
      }.done {
        let message = isSubscribed ?
          R.string.subredditContext.unsubscribeSuccess(self.subredditName) :
          R.string.subredditContext.subscribeSuccess(self.subredditName)
        
        Overlay.shared.flashSuccessOverlay(message)
        
      }.catch { _ in
        Overlay.shared.flashErrorOverlay(R.string.subredditContext.subscriptionError())
      }
      
    }
    
    return action
  }
  
  @available(iOS 13.0, *)
  private func sideBarAction() -> UIMenuElement {
    
    let action = UIAction(
      title: R.string.subredditContext.sidebarTitle(),
      image: UIImage(systemSymbol: .sidebarRight)) { [unowned self] _ in
        let controller = SideBarViewController(subredditName: self.subredditName)
        SplitCoordinator.current.splitViewController.show(controller, sender: self)
    }
    
    return action
  }
  
  // MARK: - Context Menu Extension
  
  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
    guard let animator = animator else {
      listingRef = nil
      return
    }

    animator.addCompletion { [weak self] in
      self?.listingRef = nil
    }

  }
  
  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
    guard let controller = listingRef else { return }
    
    animator.addCompletion {
      SplitCoordinator.current.splitViewController.display(controller)
    }
  }
  
}
