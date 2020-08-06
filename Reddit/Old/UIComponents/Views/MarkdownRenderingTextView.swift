//
//  MarkdownRenderingTextView.swift
//  Reddit
//
//  Created by made2k on 9/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import Marklight
import RxSwift

class MarkdownRenderingTextView: UITextView {

  private var storage: MarklightTextStorage!
  var processor: MarklightTextProcessor {
    return storage.marklightTextProcessor
  }

  private weak var specialDelegate: UITextViewDelegate?

  override var delegate: UITextViewDelegate? {
    get {
      return self
    }
    set {
      specialDelegate = newValue
    }
  }
  
  private let disposeBag = DisposeBag()

  convenience init() {
    let storage = MarklightTextStorage()

    let layoutManager = NSLayoutManager()
    storage.addLayoutManager(layoutManager)

    let textContainer = NSTextContainer()
    layoutManager.addTextContainer(textContainer)

    self.init(frame: .zero, textContainer: textContainer)

    self.storage = storage
    registerThemes()
  }

  override var textColor: UIColor? {
    didSet {
      processor.textColor = textColor ?? .black
    }
  }

  func registerThemes() {
    backgroundColor = .systemBackground
    textColor = .label

    processor.linkColor = .link
    processor.codeColor = .secondaryLabel
  }


  /**
   This function will intercept the text to continue markdown. For example
   if the line has a list 1. someText pressing enter will continue that
   list with 2. SomeText
   */
  private func continueMarkdown(with text: String, in range: NSRange) -> Bool {
    guard text == "\n" else { return true }
    guard let originalText = self.text else { return true }

    var returnValue = true
    let enumerateRange = originalText.startIndex..<originalText.index(originalText.startIndex, offsetBy: range.location)

    // We start at cursor position and look at the previous paragraph
    originalText.enumerateSubstrings(in: enumerateRange, options: [.byParagraphs, .reverse]) { (string, innerRange, _, stop) in
      guard let string = string else { stop = true; return }

      let convertedRange = NSRange(innerRange, in: originalText)
      guard convertedRange.location + convertedRange.length >= range.location else { stop = true; return }

      if string.hasPrefix("* ") {
        // We need to have text to continue the list, if we don't we remove the spacing
        if string.rangeOfCharacter(from: CharacterSet(charactersIn: "* ").inverted) != nil {
          returnValue = !self.safeInsert("\n* ", at: range.location)

        } else {
          self.text.removeSubrange(innerRange)
          self.selectedRange = NSRange(location: range.location - 2, length: 0)
          returnValue = false
        }

        // This check needs to make sure we have a number, and then that there's additional text
        // after that number
      } else if let first = string.first, let number = Int(first.description), string.hasPrefix("\(number). ") {

        if string.substring(after: "\(number). ")?.isEmpty == false {
          returnValue = !self.safeInsert("\n\(number + 1). ", at: range.location)

        } else {
          self.text.removeSubrange(innerRange)
          self.selectedRange = NSRange(location: range.location - 3, length: 0)
          returnValue = false
        }
      }

      stop = true
    }

    return returnValue
  }

  private func safeInsert(_ newText: String, at offset: Int) -> Bool {
    guard offset <= self.text.count else { return false }

    let index = self.text.index(self.text.startIndex, offsetBy: offset)
    self.text.insert(contentsOf: newText, at: index)

    let location = offset + newText.count
    self.selectedRange = NSRange(location: location, length: 0)

    return true
  }
}

// MARK: - Delegate

extension MarkdownRenderingTextView: UITextViewDelegate {

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if specialDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) == false {
      return false
    }

    return continueMarkdown(with: text, in: range)
  }

  // MARK: Passthrough

  func textViewDidChange(_ textView: UITextView) {
    specialDelegate?.textViewDidChange?(textView)
  }

  func textViewDidChangeSelection(_ textView: UITextView) {
    specialDelegate?.textViewDidChangeSelection?(textView)
  }

  func textViewDidBeginEditing(_ textView: UITextView) {
    specialDelegate?.textViewDidBeginEditing?(textView)
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    specialDelegate?.textViewDidEndEditing?(textView)
  }

  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    return specialDelegate?.textViewShouldEndEditing?(textView) ?? true
  }

  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    return specialDelegate?.textViewShouldBeginEditing?(textView) ?? true
  }
}
