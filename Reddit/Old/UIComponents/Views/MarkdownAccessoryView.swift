//
//  MarkdownAccessoryView.swift
//  Reddit
//
//  Created by made2k on 6/4/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit

class MarkdownAccessoryView: UIView {
  
  weak var delegate: MarkdownAccessoryProtocol?
  
  private let boldButton = BoldButton()
  private let italicButton = ItalicButton()
  private let strikeButton = StrikeButton()
  private let codeButton = CodeButton()
  private let quoteButton = QuoteButton()
  private let superButton = SuperScriptButton()
  private let listButton = ListButton()
  private let orderedListButton = OrderedListButton()

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {

    backgroundColor = .systemGray3
    
    let scrollview = UIScrollView(frame: .zero)
    scrollview.showsHorizontalScrollIndicator = false
    scrollview.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 24
    stackView.alignment = .center

    stackView.addArrangedSubview(boldButton)
    boldButton.addTarget(self, action: #selector(bold), for: .touchUpInside)
    stackView.addArrangedSubview(italicButton)
    italicButton.addTarget(self, action: #selector(italic), for: .touchUpInside)
    stackView.addArrangedSubview(strikeButton)
    strikeButton.addTarget(self, action: #selector(strike), for: .touchUpInside)
    stackView.addArrangedSubview(codeButton)
    codeButton.addTarget(self, action: #selector(code), for: .touchUpInside)
    stackView.addArrangedSubview(quoteButton)
    quoteButton.addTarget(self, action: #selector(quote), for: .touchUpInside)
    stackView.addArrangedSubview(superButton)
    superButton.addTarget(self, action: #selector(superscript), for: .touchUpInside)
    stackView.addArrangedSubview(listButton)
    listButton.addTarget(self, action: #selector(list), for: .touchUpInside)
    stackView.addArrangedSubview(orderedListButton)
    orderedListButton.addTarget(self, action: #selector(orderedList), for: .touchUpInside)
    
    scrollview.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    addSubview(scrollview)
    scrollview.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  
  @objc private func bold() {
    delegate?.bold()
  }
  
  @objc private func italic() {
    delegate?.italic()
  }

  @objc private func strike() {
    delegate?.strike()
  }
  
  @objc private func code() {
   delegate?.code()
  }
  
  @objc private func quote() {
    delegate?.quote()
  }
  
  @objc private func superscript() {
    delegate?.superscript()
  }
  
  @objc private func list() {
    delegate?.listItem()
  }
  
  @objc private func orderedList() {
    delegate?.orderedListItem()
  }
}

private class InputButton: UIButton {
  
  fileprivate let mainColor: UIColor = .label
  fileprivate let secondaryColor: UIColor = .secondaryLabel
  fileprivate let highlightColor: UIColor = UIColor(hex: "4185f2")

  fileprivate let baseFont = Settings.fontSettings.fontValue
  fileprivate var boldFont: UIFont {
    return baseFont.bold
  }
  fileprivate var italicFont: UIFont {
    return baseFont.italic
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  func setup() { /* Needs override */ }
}

private class BoldButton: InputButton {
  
  override func setup() {
    
    let attributed = NSMutableAttributedString(string: "**Bold**", attributes: [
      .foregroundColor: mainColor,
      .font: baseFont
      ])
    
    attributed.addAttributesToSubstring("**", attributes: [
      .foregroundColor: secondaryColor
      ])
    
    attributed.addAttributesToSubstring("Bold", attributes: [
      .font: boldFont
      ])
    
    setAttributedTitle(attributed, for: .normal)
  }
  
}

private class ItalicButton: InputButton {
  
  override func setup() {
    
    let attributed = NSMutableAttributedString(string: "*Italic*", attributes: [
      .foregroundColor: mainColor,
      .font: baseFont
      ])
    
    attributed.addAttributesToSubstring("*", attributes: [
      .foregroundColor: secondaryColor
      ])
    
    attributed.addAttributesToSubstring("Italic", attributes: [
      .font: italicFont
      ])
    
    setAttributedTitle(attributed, for: .normal)
  }
}

private class StrikeButton: InputButton {
  
  override func setup() {
    
    let attributed = NSMutableAttributedString(string: "Strike", attributes: [
      .foregroundColor: mainColor,
      .font: baseFont,
      .strikethroughStyle: NSUnderlineStyle.thick.rawValue,
      .strikethroughColor: highlightColor
      ])
    
    setAttributedTitle(attributed, for: .normal)
  }
}

private class CodeButton: InputButton {
  
  override func setup() {
    
    let attributed = NSMutableAttributedString(string: "`Code`", attributes: [
      .foregroundColor: mainColor,
      .font: baseFont
      ])
    
    attributed.addAttributesToSubstring("`", attributes: [
      .foregroundColor: secondaryColor
      ])
    
    attributed.addAttributesToSubstring("Code", attributes: [
      .font: UIFont.monospacedDigitSystemFont(ofSize: baseFont.pointSize, weight: .regular)
      ])
    
    setAttributedTitle(attributed, for: .normal)
  }
}

private class QuoteButton: InputButton {
  
  override func setup() {
    
    let attributed = NSMutableAttributedString(string: "> Quote", attributes: [
      .foregroundColor: mainColor,
      .font: baseFont
      ])
    
    attributed.addAttributesToSubstring(">", attributes: [
      .foregroundColor: secondaryColor
      ])
    
    setAttributedTitle(attributed, for: .normal)
  }
}

private class SuperScriptButton: InputButton {
  
  override func setup() {
    
    let attributed = NSMutableAttributedString(string: "^Super", attributes: [
      .foregroundColor: mainColor,
      .font: baseFont
      ])
    
    attributed.addAttributesToSubstring("^", attributes: [
      .foregroundColor: secondaryColor
      ])
    
    attributed.addAttributesToSubstring("Super", attributes: [
      .baselineOffset: 5,
      .font: baseFont.withSize(baseFont.pointSize - 5)
      ])
    
    setAttributedTitle(attributed, for: .normal)
  }
}

private class ListButton: InputButton {
  
  override func setup() {
    
    let attributed = NSMutableAttributedString(string: "• List", attributes: [
      .foregroundColor: mainColor,
      .font: baseFont
      ])
    
    attributed.addAttributesToSubstring("•", attributes: [
      .foregroundColor: secondaryColor
      ])
    
    setAttributedTitle(attributed, for: .normal)
  }
}

private class OrderedListButton: InputButton {
  
  override func setup() {
    
    let attributed = NSMutableAttributedString(string: "1. List", attributes: [
      .foregroundColor: mainColor,
      .font: baseFont
      ])
    
    attributed.addAttributesToSubstring("1.", attributes: [
      .foregroundColor: secondaryColor
      ])
    
    setAttributedTitle(attributed, for: .normal)
  }
}
