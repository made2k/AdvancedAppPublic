//
//  ViewProvidingUrlPreviewContext.swift
//  Reddit
//
//  Created by made2k on 8/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

/**
  A URLPreviewContext that uses it's parent as the preview target.
 */
class ParentContextUrlPreview: UrlPreviewContextMenu {
  
  private var view: UIView?

  init(url: URL) {
    super.init(url: url, mediaSize: nil)
  }
  
  override func register(view: UIView) {
    super.register(view: view)
    self.view = view
  }
  
  @available(iOS 13.0, *)
  private func createPreview() -> UITargetedPreview? {
    guard let view = self.view else { return nil }
    guard let parent = view.superview else { return nil }
    
    let parameters = UIPreviewParameters()
    
    let visibleRect = view.convert(view.bounds, to: parent)
    let center = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    parameters.visiblePath = UIBezierPath(rect: visibleRect)
    
    let target = UIPreviewTarget(container: parent, center: center)
    
    let preview = UITargetedPreview(view: view, parameters: parameters, target: target)
    return preview
  }
  
  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    return createPreview()
  }
  
  @available(iOS 13.0, *)
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    return createPreview()
  }
  
}
