//
//  PreviewImage.swift
//  RedditAPI
//
//  Created by made2k on 6/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public protocol PreviewImage {
  var id: String? { get }
  var source: PreviewImageInstance { get }
  var resolutions: [PreviewImageInstance] { get }
  var variants: PreviewVariant? { get }
}
