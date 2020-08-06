//
//  Preview.swift
//  RedditAPI
//
//  Created by made2k on 6/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct Preview: Decodable {
  
  public let enabled: Bool
  public let images: [PreviewImage]
  public let previewVideo: RedditVideo?

  private enum CodingKeys: String, CodingKey {
    case enabled
    case images
    case previewVideo = "reddit_video_preview"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.enabled = try container.decode(.enabled)
    self.previewVideo = try container.decodeIfPresent(.previewVideo)

    var imageContainer = try container.nestedUnkeyedContainer(forKey: .images)
    var images: [PreviewImage] = []

    while imageContainer.isAtEnd == false {
      let image: VariantPreviewInstance = try imageContainer.decode(VariantPreviewInstance.self)
      images.append(image)
    }

    self.images = images
  }
  
}
