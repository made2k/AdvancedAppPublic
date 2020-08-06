//
//  ListingsCellFactory.swift
//  Reddit
//
//  Created by made2k on 1/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

struct ListingsCellFactory {

  static func cellFor(model: LinkModel, previewType: PreviewType, delegate: ListingsCellDelegate?) -> ListingsCellNode {

    switch previewType {

    case .preview:
      if Settings.previewTitleFirst.value {
        return TitleFirstPreviewCellNode(model: model, delegate: delegate)
      }
      return PreviewListingsCellNode(model: model, delegate: delegate)

    case .thumbnail:
      return ThumbnailListingsCellNode(model: model, delegate: delegate)
    }

  }

}
