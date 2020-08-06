//
//  SharedListingsCellDelegate.swift
//  Reddit
//
//  Created by made2k on 8/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import PromiseKit

class SharedListingsCellDelegate: NSObject, ListingsCellDelegate {
  
  static let shared = SharedListingsCellDelegate()
  
  private override init() { }

  func canMarkAboveAsRead(for model: LinkModel) -> Bool {
    return false
  }
  
  func listingCellDidOpenUser(_ name: String) {
    LinkHandler.openRedditUser(userName: name)
  }
  
  func listingCellToggledHidden(for model: LinkModel) -> Promise<Void> {
    
    return firstly {
      model.setHidden(!model.hidden.value)
      
    }.recover { error in
      Overlay.shared.flashErrorOverlay(R.string.listings.errorHidingPost())
      throw error
    }
    
  }
  
  func listingCellToggledSave(for model: LinkModel) -> Promise<Void> {
    
    return firstly {
      model.setSaved(!model.saved.value)
      
    }.done {
      let message = model.saved.value ?
        R.string.listings.saveSuccess() :
        R.string.listings.unsaveSuccess()
      Overlay.shared.flashSuccessOverlay(message)
      
    }.recover { error in
      Overlay.shared.flashErrorOverlay(R.string.listings.errorSavingPost())
      throw error
    }
    
  }
  
  func listingCellDidCopyLinkUrl(url: URL) {
    UIPasteboard.general.string = url.absoluteString
    Overlay.shared.flashSuccessOverlay("Link copied to clipboard")
  }
  
  func listingCellDidDelete(model: LinkModel) -> Promise<Void> {
    
    Overlay.shared.showProcessingOverlay()

    return firstly {
      model.delete()

    }.done {
      Overlay.shared.hideProcessingOverlay()

    }.recover { error in
      Overlay.shared.flashErrorOverlay(R.string.listings.errorDeletingPost())
      throw error
    }

  }
  
  func listingCellMarkedRead(above model: LinkModel) { /* Not handled */ }
  
  func listingCellDidFilter(model: LinkModel, subtype: FilterSubtype) {
    let vc = FilterCreateViewController(filterType: .post, subtype: subtype, prefill: model.link)
    let nav = NavigationController()

    nav.viewControllers = [vc]
    nav.modalPresentationStyle = .formSheet
    if #available(iOS 13.0, *) {
      nav.isModalInPresentation = true
    }
    
    SplitCoordinator.current.topViewController.present(nav)
  }

  func listingsCellDidHide(for model: LinkModel) { /* unimplemented, others should handle */ }

  func listingCellDidStartReply(for model: LinkModel) {
    CommentCreateCoordinator(
      presenting: SplitCoordinator.current.topViewController,
      replyName: model.name,
      delegate: nil)
      .start()
  }
  
}
