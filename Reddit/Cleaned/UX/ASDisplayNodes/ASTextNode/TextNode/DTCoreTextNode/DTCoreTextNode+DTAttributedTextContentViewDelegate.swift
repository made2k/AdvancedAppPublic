//
//  DTCoreTextNode+DTAttributedTextContentViewDelegate.swift
//  Reddit
//
//  Created by made2k on 8/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import DTCoreText

extension DTCoreTextNode: DTAttributedTextContentViewDelegate {

  private var spoilerLinks: Set<String> {
    return [
      "/spoiler",
      "#spoiler",
      "#s",
      "/s",
      "#p", // GOT subreddit
      "#b" // GOT Subreddit
    ]
  }

  // MARK: - Delegate

  /// Return a previewing link button
  func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewForLink url: URL!, identifier: String!, frame: CGRect) -> UIView! {

    let button = PreviewingLinkButton(frame: frame, url: url, identifier: identifier)
    button.minimumHitSize = CGSize(width: 25, height: 20)

    if isSpoiler(url: url) {
      // If we show spoilers, then we don't need to do anything, and dont need
      // a button here since it just acts as text
      if Settings.showSpoilers == true { return nil }

      // Make the background color the same as the text color, that way it covers it fully
      button.backgroundColor = textColor
    }

    // Tap Action
    button.addTargetClosure { [weak self] in self?.linkPressed(sender: button) }
    // Long Press Action
    button.onLongPress { [weak self] gesture in self?.linkLongPressed(sender: gesture) }

    return button
  }

  /**
   Here we check if we have a block of code or of a quote. If so, we change the background color for each.
   If it's a quote, the text color should be different, and a background "bar" is added.
   If it's a code block, a background is drawn that has a different color as well as a border.
   */
  func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, shouldDrawBackgroundFor textBlock: DTTextBlock!, frame: CGRect, context: CGContext!, for layoutFrame: DTCoreTextLayoutFrame!) -> Bool {

    if textBlock.backgroundColor == CSSMatchers.Color.quote {
      let inset: CGFloat = 0
      let width: CGFloat = 3
      let leadingFrame = CGRect(x: frame.origin.x + inset, y: frame.origin.y, width: width, height: frame.size.height)
      let leadingRect = UIBezierPath.init(roundedRect: leadingFrame, cornerRadius: width/2)
      //54a3ce off blue color if ever want to switch
      context.setFillColor(UIColor(hex: "c4c4c4").withAlphaComponent(0.65).cgColor)
      context.addPath(leadingRect.cgPath)
      context.fillPath()

      return false
    }

    if textBlock.backgroundColor == CSSMatchers.Color.code {
      let roundedRect = UIBezierPath(roundedRect: CGRect(origin: frame.origin, size: frame.size).insetBy(dx: 1, dy: 1), cornerRadius: 10)
      context.setFillColor(CSSMatchers.Color.code.withAlphaComponent(0.73).cgColor)
      context.addPath(roundedRect.cgPath)
      context.fillPath()

      context.addPath(roundedRect.cgPath)
      context.setStrokeColor(red: 110.0/255.0, green: 121.0/255.0, blue: 127.0/255.0, alpha: 1)
      context.strokePath()
      return false
    }

    return true
  }

  // MARK: - Helpers

  private func linkPressed(sender: DTLinkButton) {
    if isSpoiler(url: sender.url) {
      showSpoiler(url: sender.url, button: sender)

    } else {
      // Call in to the text node delegate to handle the link
      delegate?.textNode?(self, tappedLinkAttribute: "", value: sender.url, at: sender.center, textRange: NSRange(location: 0, length: 0))
    }
  }

  private func isSpoiler(url: URL) -> Bool {
    return spoilerLinks.contains(url.absoluteString) ||
      url.absoluteString.starts(with: "/s") ||
      url.scheme == URL.CustomSchemes.spoiler
  }

  private func showSpoiler(url: URL, button: DTLinkButton) {

    let allButtons = view.subviews.filter { $0 is DTLinkButton } as? [DTLinkButton] ?? []
    let showingButtons = allButtons.filter { $0.guid == button.guid }

    showingButtons.forEach {
      $0.backgroundColor = .clear
      $0.isUserInteractionEnabled = false
    }
  }

  private func linkLongPressed(sender: UILongPressGestureRecognizer) {
    guard sender.state == .began else { return }
    guard let button = sender.view as? DTLinkButton else { return }

    if isSpoiler(url: button.url) {
      showSpoiler(url: button.url, button: button)

    } else {
      delegate?.textNode?(self, longPressedLinkAttribute: "", value: button.url, at: button.center, textRange: NSRange(location: 0, length: 0))
    }
  }

}
