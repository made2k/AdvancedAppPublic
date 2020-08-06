//
//  Flair.swift
//  RedditAPI
//
//  Created by made2k on 6/19/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct Flair: Decodable {

  public let images: [URL]
  public let text: String?
  public let backgroundColor: UIColor?

  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()

    var images: [URL] = []
    var text: String?

    while container.isAtEnd == false {
      let instance: FlairInstance = try container.decode(FlairInstance.self)

      switch instance {
      case .emoji(let url):
        images.append(url)

      case .text(let value):
        text = value
      }

    }

    self.images = images
    self.text = text
    self.backgroundColor = nil
  }

  init(flair: Flair, backgroundColor: UIColor) {
    self.images = flair.images
    self.text = flair.text
    self.backgroundColor = backgroundColor
  }
  
}
