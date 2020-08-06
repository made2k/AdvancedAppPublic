//
//  DTCoreTextStyles.swift
//  Reddit
//
//  Created by made2k on 1/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import DTCoreText

struct CSSMatchers  {
  struct Color {
    static let quote = UIColor(hex: "f2f2f2")
    static let code = UIColor(hex: "D3D3D3")
  }
  struct TextColor {
    static let quote = "#2C2C2C"
  }
}

class DTCoreTextStyles: NSObject {
  
  static func setup() {
    setupLinks()
    setupCode()
    setupQuotes()
    setupHeaders()
  }
  
  static func setupLinks() {
    let linkStyle =
    """
      a
      {
        color:#3182D9;
        text-decoration:underline;
      }
      a:active
      {
        color:#3182D9;
      }
      """
    let link = DTCSSStylesheet(styleBlock: linkStyle)
    DTCSSStylesheet.defaultStyleSheet().merge(link)
  }
  
  static func setupCode() {
    let codeBlockStyle =
    """
    code {
      background-color:#d3d5d7;
      color:#4b4d4f;
    }
    pre code
    {
      color:#2B2B2B;
      background-color:inherit;
    }
    pre, code
    {
      padding: 10px;
      font-family:monospace;
      white-space:pre;
      background-color:\(CSSMatchers.Color.code.hexString(false));
    }
    """
    let codeBlocks = DTCSSStylesheet(styleBlock: codeBlockStyle)
    DTCSSStylesheet.defaultStyleSheet().merge(codeBlocks)

  }
  
  static func setupQuotes() {
    let quoteBlockStyle =
    """
    blockquote
    {
      color:\(CSSMatchers.TextColor.quote);
      background-color:\(CSSMatchers.Color.quote.hexString(false));
    }
    """
    let quoteBlock = DTCSSStylesheet(styleBlock: quoteBlockStyle)
    DTCSSStylesheet.defaultStyleSheet().merge(quoteBlock)
  }
  
  static func setupHeaders() {
    let headerStyle =
    """
    h1, h2, h3, h4, h5, h6
    {
      font-size:inherit;
      -webkit-margin-before:1em;
      -webkit-margin-after:1em;
      -webkit-margin-start:0;
      -webkit-margin-end:0;
      font-weight:bold;
    }
    """
    let headerBlock = DTCSSStylesheet(styleBlock: headerStyle)
    DTCSSStylesheet.defaultStyleSheet().merge(headerBlock)
  }
  
  
}
