//
//  LinkCoordinator+CommentSort.swift
//  Reddit
//
//  Created by made2k on 1/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

extension LinkCoordinator {
  
  func showSortSelection() {
    
    let alert = AlertController()
    
    let types: [CommentSort] = [.confidence, .hot, .new, .controversial, .top, .old]
    
    for type in types {
      alert.addAction(sortAction(type))
    }

    alert.show()
  }
  
  private func sortAction(_ type: CommentSort) -> AlertAction {
    
    return AlertAction(title: type.displayName, icon: type.icon) { [unowned self] in
      self.changedSortType(type: type)
    }
    
  }
  
  private func changedSortType(type: CommentSort) {
    model?.commentSort.accept(type)
    model?.resetCommentTree()
    
    controller?.reloadSections([1], with: .automatic)
    
    loadComments()
  }
  
}
