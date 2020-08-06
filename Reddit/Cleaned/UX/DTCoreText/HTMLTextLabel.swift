//
//  HTMLTextLabel.swift
//  Reddit
//
//  Created by made2k on 2/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import DTCoreText
import UIKit

class HTMLTextLabel: DTAttributedLabel {

  static let textInsetSize: CGFloat = 8

  var textColor: UIColor? {
    didSet {
      guard textColor != nil else { return }
      reloadHTML()
    }
  }

  private var htmlString: String = ""

  init(htmlString: String) {

    super.init(frame: .zero)

    let inset = HTMLTextLabel.textInsetSize
    edgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)

    setHTML(htmlString)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setHTML(_ htmlString: String) {

    self.htmlString = htmlString

    var customAttributes: [String: Any] = [:]

    if let color = textColor {
      customAttributes[DTDefaultTextColor] = color
    }

    let attributedString = htmlString.processHtmlString(options: customAttributes)
    self.attributedString = attributedString
  }

  private func reloadHTML() {
    setHTML(htmlString)
  }

}
