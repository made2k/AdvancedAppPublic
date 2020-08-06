//
//  DTCoreTextNode.swift
//  Reddit
//
//  Created by made2k on 1/17/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import DTCoreText
import RxSwift
import UIKit
import Utilities

final class DTCoreTextNode: TextNode {
    
  // Override this in order to set the intrinsic value on the main thread.
  // We also don't actually display text with the text node. That instead is done
  // with the DTAttributedTextContentView
  override var attributedText: NSAttributedString? {
    get { return _intrinsicAttributedText }
    set { _intrinsicAttributedText = newValue }
  }
  
  private var _intrinsicAttributedText: NSAttributedString? {
    didSet {
      guard isNodeLoaded else { return }
      DispatchQueue.main.async {
        self.textView?.attributedString = self._intrinsicAttributedText
      }
    }
  }
  
  var textView: DTAttributedTextContentView? {
    return view as? DTAttributedTextContentView
  }
  
  var html: String? {
    didSet { reload() }
  }

  var highlightLinks: Bool = true {
    didSet {
      reload()
      textView?.isUserInteractionEnabled = false
    }
  }
  
  var edgeInsets: UIEdgeInsets {
    get { return textView?.edgeInsets ?? .zero }
    set { textView?.edgeInsets = newValue }
  }
  
  private var htmlAttributes: [String: Any] {

    var attributes: [String: Any] = [:]

    attributes[DTDefaultFontSize] = font.pointSize
    attributes[DTDefaultFontFamily] = font.familyName
    // TODO: Check if this is an iOS 13 beta issue
    if font.fontName == UIFont.systemFont(ofSize: 12).fontName {
      attributes[DTDefaultFontName] = "\(font.familyName) : \(font.fontName)"
    } else {
      attributes[DTDefaultFontName] = font.fontDescriptor.postscriptName
    }

    attributes[DTDefaultTextColor] = textColor

    attributes[DTDefaultLineHeightMultiplier] = lineHeightMultiple

    if !highlightLinks {
      attributes[DTDefaultLinkColor] = textColor
    }
    
    return attributes
  }

  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  override init(weight: FontWeight = .regular, size: FontSize = .default, color: UIColor = .label) {
    super.init(weight: weight, size: size, color: color)
    
    isUserInteractionEnabled = true

    setViewBlock { [unowned self] () -> UIView in
      let textView = TiledLayerTextContentView()
      textView.delegate = self
      return textView
    }
    
  }

  // MARK: - Lifecycle
  
  override func didLoad() {
    super.didLoad()
    textView?.attributedString = _intrinsicAttributedText
    setupBindings()
  }
  
  override func reload(_ updatedText: String? = nil) {
    guard let html = html else { return }
    let rawHtmlText = html.processHtmlString(options: htmlAttributes)
    attributedText = rawHtmlText
  }

  private func setupBindings() {

    SplitCoordinator.currentObserver
      .filterNil()
      .flatMap(\.interfaceObserver)
      .distinctUntilChanged()
      .asVoid()
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        self?.reload()
      }).disposed(by: disposeBag)

  }

}

private class TiledLayerTextContentView: DTAttributedTextContentView {
  override class var layerClass : AnyClass {
    return DTTiledLayerWithoutFade.self
  }
}
