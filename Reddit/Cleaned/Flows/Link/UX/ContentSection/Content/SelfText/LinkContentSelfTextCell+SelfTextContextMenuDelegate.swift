//
//  LinkContentSelfTextCell+SelfTextContextMenuDelegate.swift
//  Reddit
//
//  Created by made2k on 8/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

extension LinkContentSelfTextCell: SelfTextContextMenuDelegate {
  
  func contextMenuDidTapToAddReply(model: LinkModel) {
    delegate?.selfTextDidSelectReply(model)
  }
  
  func contextMenuDidTapToSelectText(model: LinkModel) {
    delegate?.selfTextDidSelectText(model)
  }
  
}
