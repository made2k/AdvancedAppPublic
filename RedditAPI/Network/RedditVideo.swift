//
//  RedditVideo.swift
//  RedditAPI
//
//  Created by made2k on 6/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct RedditVideo: Decodable {
  public let fallbackUrl: URL
  public let hlsUrl: URL
  public let width: Int
  public let height: Int
  public let duration: TimeInterval
  public let isGif: Bool
}
