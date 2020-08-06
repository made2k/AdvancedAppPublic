//
//  MarkdownAccessoryProtocol.swift
//  Reddit
//
//  Created by made2k on 6/4/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import Logging

protocol MarkdownAccessoryProtocol: class {
  var markdownTextView: UITextView { get }
}

// MARK: - Text replacement

extension MarkdownAccessoryProtocol {
  
  func bold() {
    replaceWith("**")
    markdownTextView.delegate?.textViewDidChange?(markdownTextView)
  }
  
  func italic() {
    replaceWith("*")
    markdownTextView.delegate?.textViewDidChange?(markdownTextView)
  }
  
  func strike() {
    replaceWith("~~")
    markdownTextView.delegate?.textViewDidChange?(markdownTextView)
  }
  
  func code() {
    replaceWith("`")
    markdownTextView.delegate?.textViewDidChange?(markdownTextView)
  }
  
  func quote() {
    let selectedRange = markdownTextView.selectedRange
    if isSelectedContainedIn(.byParagraphs) == false {
      markdownTextView.text.insert(contentsOf: "> ", at: markdownTextView.text.index(markdownTextView.text.startIndex, offsetBy: selectedRange.location))
      return
    }

    let currentPosition = markdownTextView.selectedTextRange!.start
    let test = markdownTextView.tokenizer.position(from: currentPosition, toBoundary: .paragraph, inDirection: convertToUITextDirection(UITextStorageDirection.backward.rawValue))
    let offset = markdownTextView.offset(from: markdownTextView.beginningOfDocument, to: test!)
    
    markdownTextView.text.insert(contentsOf: "> ", at: markdownTextView.text.index(markdownTextView.text.startIndex, offsetBy: offset))
    markdownTextView.delegate?.textViewDidChange?(markdownTextView)
  }
  
  func superscript() {    
    let currentPosition = markdownTextView.selectedTextRange!.start
    let test = markdownTextView.tokenizer.position(from: currentPosition, toBoundary: .word, inDirection: convertToUITextDirection(UITextStorageDirection.backward.rawValue))
    let offset = markdownTextView.offset(from: markdownTextView.beginningOfDocument, to: test!)
    
    markdownTextView.text.insert(contentsOf: "^", at: markdownTextView.text.index(markdownTextView.text.startIndex, offsetBy: offset))
    markdownTextView.delegate?.textViewDidChange?(markdownTextView)
  }
  
  func listItem() {
    let selectedRange = markdownTextView.selectedRange
    if isSelectedContainedIn(.byParagraphs) == false {
      markdownTextView.text.insert(contentsOf: "* ", at: markdownTextView.text.index(markdownTextView.text.startIndex, offsetBy: selectedRange.location))
      return
    }

    guard let currentPosition = markdownTextView.selectedTextRange?.start else { return }
    let paragraphPosition = markdownTextView.tokenizer.position(from: currentPosition, toBoundary: .paragraph, inDirection: convertToUITextDirection(UITextStorageDirection.backward.rawValue))
    let offset = markdownTextView.offset(from: markdownTextView.beginningOfDocument, to: paragraphPosition!)
    
    markdownTextView.text.insert(contentsOf: "* ", at: markdownTextView.text.index(markdownTextView.text.startIndex, offsetBy: offset))
    markdownTextView.delegate?.textViewDidChange?(markdownTextView)
  }
  
  func orderedListItem() {
    let selectedRange = markdownTextView.selectedRange
    if isSelectedContainedIn(.byParagraphs) == false {
      markdownTextView.text.insert(contentsOf: "1. ", at: markdownTextView.text.index(markdownTextView.text.startIndex, offsetBy: selectedRange.location))
      return
    }

    let currentPosition = markdownTextView.selectedTextRange!.start
    let test = markdownTextView.tokenizer.position(from: currentPosition, toBoundary: .paragraph, inDirection: convertToUITextDirection(UITextStorageDirection.backward.rawValue))
    let offset = markdownTextView.offset(from: markdownTextView.beginningOfDocument, to: test!)
    
    markdownTextView.text.insert(contentsOf: "1. ", at: markdownTextView.text.index(markdownTextView.text.startIndex, offsetBy: offset))
    markdownTextView.delegate?.textViewDidChange?(markdownTextView)
  }

  private func isSelectedContainedIn(_ option: NSString.EnumerationOptions) -> Bool {
    guard let text = markdownTextView.text else { return false }
    let selectedRange = markdownTextView.selectedRange
    let enumerationRange = text.startIndex..<text.endIndex

    var found = false

    markdownTextView.text.enumerateSubstrings(in: enumerationRange, options: [option]) { (string, range, _, stop) in

      let convertedSmall = NSRange(range, in: text)
      if convertedSmall.location + convertedSmall.length >= selectedRange.location {
        found = true
        stop = true
      }
    }

    return found
  }
}

// MARK: - Helpers

private extension MarkdownAccessoryProtocol {
  
  private func replaceWith(_ replacementString: String) {
    if let contents = getReplaceRange(selectedRange: markdownTextView.selectedRange) {
      
      let originalCurserPosition = markdownTextView.selectedRange
      
      let newText = "\(replacementString)\(contents.0)\(replacementString)"
      let new = markdownTextView.text.replacingCharacters(in: contents.1, with: newText)
      markdownTextView.text = new
      
      let updatedLocation = originalCurserPosition.location + originalCurserPosition.length + replacementString.count
      if markdownTextView.text.count > updatedLocation {
        markdownTextView.selectedRange = NSRange(location: updatedLocation, length: 0)
      }
      
    } else {
      let cursorPosition = markdownTextView.selectedRange
      let insertIndex =  markdownTextView.text.index(markdownTextView.text.startIndex, offsetBy: cursorPosition.location)
      let doubledString = "\(replacementString)\(replacementString)"
      markdownTextView.text.insert(contentsOf: doubledString, at: insertIndex)
      markdownTextView.selectedRange = NSRange(location: cursorPosition.location + replacementString.count, length: 0)
    }
  }
  
  private func getReplaceRange(selectedRange: NSRange) -> (String, Range<String.Index>)? {
    var content: (String, Range<String.Index>)? = nil
    let text: String = markdownTextView.text!
    
    if selectedRange.length == 0 && selectedRange.location != 0 {
      let index = text.index(text.startIndex, offsetBy: selectedRange.location-1)
      
      let textRange = text.startIndex ..< text.endIndex

      text.enumerateSubstrings(in: textRange, options: [.byWords]) { substring, range, _, exit in
        // TODO: Needs to include when cursor on punctuation.
        if range.contains(index) {
          content = (substring!, range)
          exit = false
        } else {
          log.warn("more than empty")
        }
      }
    } else {
      let substring = (text as NSString).substring(with: selectedRange)
      let startIndex = text.index(text.startIndex, offsetBy: selectedRange.location)
      let endIndex = text.index(startIndex, offsetBy: selectedRange.length)
      let range: Range<String.Index> = startIndex ..< endIndex
      
      content = (substring, range)
    }
    
    return content
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUITextDirection(_ input: Int) -> UITextDirection {
	return UITextDirection(rawValue: input)
}
