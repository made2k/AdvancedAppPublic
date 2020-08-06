//
//  SelfTextContextMenu.swift
//  Reddit
//
//  Created by made2k on 8/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

final class SelfTextContextMenu: ContextMenu {
  
  private let model: LinkModel
  private weak var delegate: SelfTextContextMenuDelegate?
  
  override var actionProvider: UIContextMenuActionProvider? {
    guard #available(iOS 13.0, *) else { return nil }
    return { [unowned self] _ in self.createMenu() }
  }
  
  init(model: LinkModel, delegate: SelfTextContextMenuDelegate) {
    self.model = model
    self.delegate = delegate
  }
  
  @available(iOS 13.0, *)
  private func createMenu() -> UIMenu? {
    
    let children: [UIMenuElement] = [
      selectTextAction(model),
      addReplyAction(model)
      ].compactMap { $0 }
    
    let menu = UIMenu(title: "", children: children)
    return menu
  }
  
  @available(iOS 13.0, *)
  private func selectTextAction(_ model: LinkModel) -> UIAction {
    let action = UIAction(
      title: R.string.selfTextContext.selectTextTitle(),
      image: UIImage(systemSymbol: .textCursor)) { [weak self] _ in
        self?.delegate?.contextMenuDidTapToSelectText(model: model)
    }
    
    return action
  }
  
  @available(iOS 13.0, *)
  private func addReplyAction(_ model: LinkModel) -> UIAction? {
    guard AccountModel.currentAccount.value.isSignedIn else { return nil }
    guard model.link.archived == false else { return nil }
    
    let action = UIAction(
      title: R.string.selfTextContext.addCommentTitle(),
      image: UIImage(systemSymbol: .arrowshapeTurnUpLeftCircle)) { [weak self] _ in
        self?.delegate?.contextMenuDidTapToAddReply(model: model)
    }
    
    return action
  }

}
