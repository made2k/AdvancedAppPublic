//
//  ContextMenu.swift
//  Reddit
//
//  Created by made2k on 8/10/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

class ContextMenu: NSObject, UIContextMenuInteractionDelegate {

  var contextMenuIdentifier: NSCopying? { return nil }
  var previewProvider: UIContextMenuContentPreviewProvider? { return nil }
  var actionProvider: UIContextMenuActionProvider? { return nil }

  func register(view: UIView) {

    if #available(iOS 13.0, *) {
      let interaction = UIContextMenuInteraction(delegate: self)
      view.addInteraction(interaction)
    }

  }

  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

    guard previewProvider != nil || actionProvider != nil else { return nil }

    return UIContextMenuConfiguration(identifier: contextMenuIdentifier,
                                      previewProvider: previewProvider,
                                      actionProvider: actionProvider)
  }

}
