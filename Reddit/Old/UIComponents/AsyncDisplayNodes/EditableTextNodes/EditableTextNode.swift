//
//  EditableTextNode.swift
//  Reddit
//
//  Created by made2k on 6/5/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class EditableTextNode: ASEditableTextNode {
  
  // TODO: Duplicate code in TextNode
  private static let defaultFontColor = UIColor(hex: "1B1B1C")
  private static let defaultPlaceholderColor = UIColor(hex: "606060")
  private static var defaultParagraphStyle: NSMutableParagraphStyle {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .natural
    paragraph.lineHeightMultiple = 1
    return paragraph
  }

  var placeholderTextColor: UIColor = EditableTextNode.defaultPlaceholderColor {
    didSet {
      let text = self.placeholderText
      self.placeholderText = text
    }
  }
  
  private var customAttributes: [NSAttributedString.Key: Any] = [
    .font: Settings.fontSettings.fontValue,
    .foregroundColor: EditableTextNode.defaultFontColor,
    .paragraphStyle: EditableTextNode.defaultParagraphStyle
    ]
    {
    didSet {
      var stringDict = [String: Any]()
      for (key, value) in customAttributes {
        stringDict[key.rawValue] = value
      }
      
      typingAttributes = stringDict
    }
  }
  private var placeholderAttributes: [NSAttributedString.Key: Any] {
    var attributes = customAttributes
    attributes[.foregroundColor] = placeholderTextColor
    return attributes
  }
  
  var font: UIFont {
    get {
      return customAttributes[.font] as? UIFont ?? Settings.fontSettings.fontValue
    }
    set {
      customAttributes[.font] = newValue
      reloadAttributedString()
    }
  }
  
  var textColor: UIColor {
    get {
      return customAttributes[.foregroundColor] as? UIColor ?? EditableTextNode.defaultFontColor
    }
    set {
      customAttributes[.foregroundColor] = newValue
      reloadAttributedString()
    }
  }
  
  var text: String? {
    get {
      return attributedText?.string
    }
    set {
      if let newValue = newValue {
        attributedText = NSAttributedString(string: newValue, attributes: customAttributes)
      } else {
        attributedText = nil
      }
    }
  }

  var placeholderText: String? {
    get {
      return attributedPlaceholderText?.string
    }
    set {
      if let newValue = newValue {
        attributedPlaceholderText = NSAttributedString(string: newValue, attributes: placeholderAttributes)
      } else {
        attributedPlaceholderText = nil
      }
    }
  }

  var lineHeightMultiple: CGFloat {
    get {
      return paragraphStyle.lineHeightMultiple
    }
    set {
      let paragraph = self.paragraphStyle
      paragraph.lineHeightMultiple = newValue
      paragraphStyle = paragraph
    }
  }
  
  private var paragraphStyle: NSMutableParagraphStyle {
    get {
      let paragraph = customAttributes[.paragraphStyle] as? NSParagraphStyle ?? NSParagraphStyle()
      return paragraph.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
    }
    set {
      customAttributes[.paragraphStyle] = newValue
    }
  }
  
  private func reloadAttributedString() {
    let text = self.text
    self.text = text
  }

}
