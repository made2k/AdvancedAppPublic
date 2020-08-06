//
//  ImagePreviewViewController.swift
//  Reddit
//
//  Created by made2k on 8/10/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

/**
 This is a view controller that displays a static image or a gif. There are no additional actions
 on this controller since it is used for previewing only.
 */
class ImagePreviewViewController: BaseMediaViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.removeGestureRecognizers()
  }

  override func mediaSizeDidChange(_ size: CGSize) {
    let safeSize = size.aspectFit(to: view.size)
    guard preferredContentSize != safeSize else { return }
    preferredContentSize = safeSize
  }

}
