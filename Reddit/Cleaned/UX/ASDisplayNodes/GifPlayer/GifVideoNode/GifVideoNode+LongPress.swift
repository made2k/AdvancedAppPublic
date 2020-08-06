//
//  GifVideoNode+LongPress.swift
//  Reddit
//
//  Created by made2k on 2/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension GifVideoNode {

  func didLongPress(gesture: UILongPressGestureRecognizer) {

    guard gesture.state == UIGestureRecognizer.State.began else { return }

    guard let player = player else { return }
    guard let currentItem = player.currentItem else { return }

    let fileUrl: URL?

    if let url = url {
      fileUrl = VideoDownloader.shared.filePath(for: url)

    } else {
      fileUrl = nil
    }

    GifLongPressHandler.handleLongPress(player: player,
                                        item: currentItem,
                                        webUrl: url,
                                        fileUrl: fileUrl,
                                        gesture: gesture)

  }

}
