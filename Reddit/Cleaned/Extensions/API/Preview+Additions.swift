//
//  Preview+Additions.swift
//  Reddit
//
//  Created by made2k on 4/1/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import RedditAPI

extension Preview {

  // MARK: - Preview Info

  var heightAspectRatio: CGFloat {
    guard sourceSize.height > 0 else { return 0 }
    return sourceSize.height / sourceSize.width
  }

  var sourceSize: CGSize {

    guard let image = images.map(\.source).first else {
      return .zero
    }

    return CGSize(width: image.width, height: image.height)
  }

  // MARK: - Quick Variants

  public var gif: PreviewImage? {
    return images.compactMap(\.variants?.gif).first
  }
  public var mp4: PreviewImage? {
    return images.compactMap(\.variants?.mp4).first
  }
  public var obfuscated: PreviewImage? {
    return images.compactMap(\.variants?.obfuscated).first
  }
  public var nsfw: PreviewImage? {
    return images.compactMap(\.variants?.nsfw).first
  }

  public func previewFitting(_ width: CGFloat) -> PreviewImageInstance? {

    guard let image = images.first else {
      return nil
    }

    return bestPreview(fitting: Int(width), using: image)
  }

  public func obfuscatedFitting(_ width: CGFloat) -> PreviewImageInstance? {

    guard let obfuscated = images.compactMap(\.variants?.obfuscated).first else {
      return nil
    }

    return bestPreview(
      fitting: Int(width),
      using: obfuscated,
      obeyingEnabled: false
    )
  }

  /// Given a width and media images, this function will iterate over resolutions
  /// to find the closest matching image.
  ///
  /// - Note: The image returned will NOT be smaller than the given width.
  ///
  /// - Parameters:
  ///   - width: The constrained width we will attempt to get closest too.
  ///   - image: MediaPreviewImage we'll use to search through.
  ///   - obeyingEnabled: If enabled, this will only return an image if the object is enabled. Defaults to true.
  /// - Returns: A MediaPreviewImageInstace if found.
  func bestPreview(
    fitting width: Int,
    using image: PreviewImage,
    obeyingEnabled: Bool = true
  ) -> PreviewImageInstance? {

    guard enabled || obeyingEnabled == false else {
      return nil
    }

    let possibleValues = image.resolutions + [image.source]

    return possibleValues
      .filter { $0.url.pathExtension != "gif" }
      .sorted(by: { $0.width < $1.width })
      .first(where: { $0.width >= width })
  }


  /// Find a preview smaller than the prodived width.
  ///
  /// - Parameters:
  ///   - width: Width the image must be smaller than
  ///   - obeyingEnabled: If enabled, this will not return a value if the object is disabled.
  /// - Returns: The closest matching preview instance.
  public func previewSmaller(than width: Int, obeyingEnabled: Bool = false) -> PreviewImageInstance? {

    guard enabled || obeyingEnabled == false else { return nil }

    return images
      .flatMap { $0.resolutions + [$0.source] }
      .sorted(by: { $0.width < $1.width })
      .last(where: { $0.width <= width })

  }

}
