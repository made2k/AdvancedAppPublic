//
//  NoVariantPreviewInstance.swift
//  RedditAPI
//
//  Created by made2k on 4/3/20.
//  Copyright © 2020 made2k. All rights reserved.
//

struct NoVariantPreviewInstance: Decodable, PreviewImage {
  public let id: String?
  public let source: PreviewImageInstance
  public let resolutions: [PreviewImageInstance]
  public var variants: PreviewVariant? { return nil }
}
