//
//  RedditMediaNode.swift
//  Reddit
//
//  Created by made2k on 10/27/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI
import UIKit

final class RedditMediaNode: UniversalMediaNode {

  // TODO: there's got to be another solution to allow the media view controller to show the link
  // TODO: Thoughts: I probably need a flexible overlay I can optionally set on universal node. That overlay can be constructed by reddit node, but will default to nil
  // The reddit node would then be able to tie into that overlay to manage vote buttons and such.
  // Optionally, other things can add their own overlay (think album descriptions without vote buttons).
  private let knownLink: LinkModel
  private var link: Link { return knownLink.link }
  let isMediaEnabled: Bool
  
  var hidingNSFW: Bool = true
  
  private var hasRetried: Bool = false
  private var hasAttemptedRedditFallbackIgnoreingVideo = false
  private var hasAttemptedRedditFallback = false
  
  init(linkModel: LinkModel, showSeparator: Bool = false) {
    self.knownLink = linkModel
    self.hidingNSFW = !Settings.showNSFWPreviews && linkModel.link.over18
    
    // TODO: Video unsupported at the moment, when added, this should be reevaluated
    self.isMediaEnabled = linkModel.linkType != .video &&
      (linkModel.link.media?.isGif == true || linkModel.link.preview?.images.isNotEmpty == true)

    super.init(mediaUrl: nil)

    self.showSeparator = showSeparator
    self.linkModel = linkModel

    if isMediaEnabled {
      var safeSize = link.preview?.sourceSize ?? .zero
      if safeSize == .zero {
        safeSize = CGSize(width: 16, height: 9)
      }
      setMediaSize(safeSize)

    } else {
      enableForceHide()
    }
  }

  // MARK: - Lifecycle

  override func didEnterPreloadState() {
    super.didEnterPreloadState()

    guard isMediaEnabled else { return }
    guard isLoading == false else { return }
    guard imageDownloadId == nil && videoDownloadUrl == nil else { return }
    guard hasContent == false else { return }
    
    parseLinkMedia(knownLink)
  }

  // MARK: - Media Info Fetch
  
  private func parseLinkMedia(_ model: LinkModel) {
    
    // If this image has an obscured nsfw preview, and we're hiding the nsfw media
    if let nsfwPreview = model.link.preview?.obfuscatedFitting(bounds.width)?.url, hidingNSFW {
      return setImageUrl(nsfwPreview)
    }
    
    // If the link is listed as over 18 but we don't have an obscure image, don't show
    if model.link.over18 && hidingNSFW {
      return enableForceHide()
    }

    // Check for media url
    if let mediaUrl = model.link.media?.fallbackUrl {
      return setVideoUrl(mediaUrl)
    }

    // Try showing raw image
    if let url = model.link.url, ImageExtractor.shared.supportsLink(url: url) {
      return setMediaUrl(url)
    }

    if attemptLoadFromReddit(link: model.link, ignoreVideo: false) == false {
      return enableForceHide()
    }
    
  }
  
  private func attemptLoadFromReddit(link: Link, ignoreVideo: Bool) -> Bool {
    hasAttemptedRedditFallback = true
    
    if let mp4 = link.preview?.mp4, ignoreVideo == false {
      setVideoUrl(mp4.source.url)
      return true
      
    } else if let gif = link.preview?.gif {
      setImageUrl(gif.source.url)
      return true
      
    } else if let image = link.preview?.images.first {
      setImageUrl(image.source.url)
      return true
    }
    
    return false
  }

  // MARK: - Media failures
  
  override func loadMediaFailed() {
    
    if hasRetried {

      setText("I really couldn't load this media. Tap to view on the web.")
      tapAction = { [unowned self] in
        guard let url = self.link.url else { return }
        OpenInPreference.shared.openBrowser(url: url)
      }

    } else if hasAttemptedRedditFallback == false && attemptLoadFromReddit(link: link, ignoreVideo: false) == false {
      loadMediaFailed()

    } else {
      setText("Failed to load media. Tap to try again.")
      tapAction = { [unowned self] in
        self.hasRetried = true
        self.parseLinkMedia(self.knownLink)
      }

    }
    
  }
  
  override func videoDownloadFailed(_ error: Error) {

    if hasAttemptedRedditFallback == true && hasAttemptedRedditFallbackIgnoreingVideo == false {

      if attemptLoadFromReddit(link: link, ignoreVideo: true) == false {
        loadMediaFailed()
      }

    } else {
      loadMediaFailed()
    }
  }

  // MARK: - Media Taps
  
  override func imageTapped(image: UIImage) {
    if hidingNSFW {
      clearState()

      hidingNSFW = false
      parseLinkMedia(knownLink)

      setNeedsLayout()

    } else if let model = linkModel {
      switch model.linkType {
      case .article:
        guard let url = model.link.url else { break }
        LinkHandler.handleUrl(url)

      case .selfText:
        SplitCoordinator.current.didOpenLink(model)

      case .image, .unknown, .video:
        super.imageTapped(image: image)
      }

    } else {
      super.imageTapped(image: image)
    }
  }
  
}
