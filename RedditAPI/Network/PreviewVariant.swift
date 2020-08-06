//
//  MediaPreviewVariant.swift
//  RedditAPI
//
//  Created by made2k on 6/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct PreviewVariant: Decodable {

  public let gif: PreviewImage?
  public let mp4: PreviewImage?
  public let nsfw: PreviewImage?
  public let obfuscated: PreviewImage?

  private enum CodingKeys: String, CodingKey {
    case gif
    case mp4
    case nsfw
    case obfuscated
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.gif = try container.decodeIfPresent(NoVariantPreviewInstance.self, forKey: .gif)
    self.mp4 = try container.decodeIfPresent(NoVariantPreviewInstance.self, forKey: .mp4)
    self.nsfw = try container.decodeIfPresent(NoVariantPreviewInstance.self, forKey: .nsfw)
    self.obfuscated = try container.decodeIfPresent(NoVariantPreviewInstance.self, forKey: .obfuscated)
  }

}
