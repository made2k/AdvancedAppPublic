//
//  LinkCoordinator+CommentContextMenuDelegate.swift
//  Reddit
//
//  Created by made2k on 8/15/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import UIKit

extension LinkCoordinator: CommentContextMenuDelegate {
  
  func commentContextDidEdit(model: CommentModel) {
    let coordinator = CommentEditCoordinator(presenting: navigation,
                                             editingComment: model,
                                             delegate: self)
    childCoordinator = coordinator
    coordinator.start()
  }
  
  func commentContextDidShare(model: CommentModel, sourceView: UIView) {
    
    let url = model.comment.permaLink
    let text = model.body
    
    let share = UIActivityViewController(activityItems: [url, text], applicationActivities: nil)
    share.popoverPresentationController?.sourceRect = sourceView.frame
    share.popoverPresentationController?.sourceView = sourceView

    navigation.present(share)
  }
  
  func commentContextDidReply(model: CommentModel) {
    guard model.archived == false else { return }
    self.showCommentReply(model)
  }
  
  func commentContextDidSelectText(model: CommentModel) {
    TextSelectionCoordinator(text: model.body, presenting: navigation).start()
  }
  
  func commentContextDidOpenUser(model: CommentModel) {
    LinkHandler.openRedditUser(userName: model.author)
  }
  
  func commentContextDidDelete(model: CommentModel) {
    guard model.archived == false else { return }
    
    firstly {
      model.delete()
      
    }.done {
      self.model?.commentTree?.commentDeleted(model: model)
      self.controller?.reloadSections([1], with: .automatic)
      
    }.catch { _ in
      Overlay.shared.flashErrorOverlay(R.string.link.deleteErrorMessage())
    }
    
  }
  
  func commentContextDidFilter(model: CommentModel, subType: FilterSubtype) {
    
    let vc = FilterCreateViewController(filterType: .comment,
                                        subtype: subType,
                                        prefill: model.comment)
    
    let nav = NavigationController(controllers: vc)
    nav.modalPresentationStyle = .formSheet
    if #available(iOS 13.0, *) {
      nav.isModalInPresentation = true
    }
    
    navigation.present(nav)
  }
  
}
