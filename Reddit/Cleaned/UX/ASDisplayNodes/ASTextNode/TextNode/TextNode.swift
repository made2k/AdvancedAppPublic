//
//  TextNode.swift
//  Reddit
//
//  Created by made2k on 6/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class TextNode: ASTextNode {

  // MARK: - Internal Attribute Construction

  private static let defaultFontColor = UIColor(hex: "1B1B1C")
  private static var defaultParagraphStyle: NSMutableParagraphStyle {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .natural
    paragraph.lineHeightMultiple = 1
    return paragraph
  }

  // Attributes used to construct the attributed string
  private let customAttributes: AtomicDict<NSAttributedString.Key, Any> = [
    .font: Settings.fontSettings.fontValue,
    .foregroundColor: TextNode.defaultFontColor,
    .paragraphStyle: TextNode.defaultParagraphStyle
  ]

  private func updateAttribute(_ attribute: NSAttributedString.Key, with value: Any) {
    customAttributes[attribute] = value
    reload()
  }

  // MARK: - Properties

  var alignment: NSTextAlignment {
    get {
      return paragraphStyle.alignment
    }
    set {
      guard newValue != alignment else { return }
      let updateStyle = paragraphStyle
      updateStyle.alignment = newValue
      paragraphStyle = updateStyle
    }
  }

  var font: UIFont {
    get {
      customAttributes[.font] as? UIFont ?? Settings.fontSettings.fontValue
    }
    set {
      guard newValue != font else { return }
      updateAttribute(.font, with: newValue)
    }
  }
  
  let fontObserver: Observable<UIFont>

  var lineHeightMultiple: CGFloat {
    get { return paragraphStyle.lineHeightMultiple }
    set {
      guard newValue != lineHeightMultiple else { return }
      let updateStyle = paragraphStyle
      updateStyle.lineHeightMultiple = newValue
      paragraphStyle = updateStyle
    }
  }

  private var paragraphStyle: NSMutableParagraphStyle {
    get {
      let paragraphStyle = customAttributes[.paragraphStyle] as? NSParagraphStyle ?? NSParagraphStyle()
      let copy = paragraphStyle.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
      return copy
    }
    set {
      updateAttribute(.paragraphStyle, with: newValue)
    }
  }

  var text: String? {
    get {
      attributedText?.string
    }
    set {
      guard newValue != text else { return }
      reload(newValue)
    }
  }

  var textColor: UIColor {
    get {
      customAttributes[.foregroundColor] as? UIColor ?? TextNode.defaultFontColor
    }
    set {
      guard newValue != textColor else { return }
      updateAttribute(.foregroundColor, with: newValue)
    }
  }

  private var disposeBag = DisposeBag()

  // MARK: - Initialization
  
  init(weight: FontWeight = .regular, size: FontSize = .default, color: UIColor = .label) {

    let initialFont: UIFont

    switch weight {
    case .bold: (fontObserver, initialFont) = TextNode.boldFont(with: size)
    case .light: (fontObserver, initialFont) = TextNode.lightFont(with: size)
    case .regular: (fontObserver, initialFont) = TextNode.defaultFont(with: size)
    case .semibold: (fontObserver, initialFont) = TextNode.semiboldFont(with: size)
    }
    
    super.init()
    
    font = initialFont
    textColor = color
    truncationMode = .byTruncatingTail
  }

  private static func boldFont(with size: FontSize) -> (Observable<UIFont>, UIFont) {

    let settings = FontSettings.shared

    switch size {
    case .micro: return (settings.microBoldFont(), settings.microBoldFontValue)
    case .small: return (settings.smallBoldFont(), settings.smallBoldFontValue)
    case .default: return (settings.boldFont(), settings.boldFontValue)
    case .large: return (settings.largeBoldFont(), settings.largeBoldFontValue)
    case .huge: return (settings.hugeBoldFont(), settings.hugeBoldFontValue)
    case .custom(let value): return (settings.boldFont(with: value), settings.boldFontValue.withSize(value))
    }

  }

  private static func lightFont(with size: FontSize) -> (Observable<UIFont>, UIFont) {

    let settings = FontSettings.shared

    switch size {
    case .micro: return (settings.microLightFont(), settings.microLightFontValue)
    case .small: return (settings.smallLightFont(), settings.smallLightFontValue)
    case .default: return (settings.lightFont(), settings.lightFontValue)
    case .large: return (settings.largeLightFont(), settings.largeLightFontValue)
    case .huge: return (settings.hugeLightFont(), settings.hugeLightFontValue)
    case .custom(let value): return (settings.lightFont(with: value), settings.lightFontValue.withSize(value))
    }

  }

  private static func semiboldFont(with size: FontSize) -> (Observable<UIFont>, UIFont) {

    let settings = FontSettings.shared

    switch size {
    case .micro: return (settings.microSemiboldFont(), settings.microSemiBoldFontValue)
    case .small: return (settings.smallSemiboldFont(), settings.smallSemiBoldFontValue)
    case .default: return (settings.semiboldFont(), settings.semiBoldFontValue)
    case .large: return (settings.largeSemiboldFont(), settings.largeSemiBoldFontValue)
    case .huge: return (settings.hugeSemiboldFont(), settings.hugeSemiBoldFontValue)
    case .custom(let value): return (settings.semiboldFont(with: value), settings.semiBoldFontValue.withSize(value))
    }

  }

  private static func defaultFont(with size: FontSize) -> (Observable<UIFont>, UIFont) {

    let settings = FontSettings.shared

    switch size {
    case .micro: return (settings.microFont(), settings.microFontValue)
    case .small: return (settings.smallFont(), settings.smallFontValue)
    case .default: return (settings.fontObserver(), settings.fontValue)
    case .large: return (settings.largeFont(), settings.largeFontValue)
    case .huge: return (settings.hugeFont(), settings.hugeFontValue)
    case .custom(let value): return (settings.font(with: value), settings.defaultFont.withSize(value))
    }

  }

  override func didEnterPreloadState() {
    super.didEnterPreloadState()
    setupBindings()
  }

  override func didExitPreloadState() {
    super.didExitPreloadState()
    disposeBag = DisposeBag()
  }

  // MARK: - Bindings
  
  private func setupBindings() {

    fontObserver
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] in
        self?.font = $0
      }).disposed(by: disposeBag)
  }

  // MARK: - Helpers

  func reload(_ updatedText: String? = nil) {
    guard let newText = (updatedText ?? text), newText.isNotEmpty else {
      return attributedText = nil
    }

    let attributes = customAttributes.dictValue
    let attributedString = NSAttributedString(string: newText, attributes: attributes)

    self.attributedText = attributedString
  }

}
