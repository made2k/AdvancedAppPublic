//
//  ButtonNode.swift
//  Reddit
//
//  Created by made2k on 2/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class ButtonNode: ASControlNode {

  override var isEnabled: Bool {
    didSet {
      alpha = isEnabled ? 1 : disabledAlpha
    }
  }

  override var tintColor: UIColor! {
    didSet {
      let safeColor = tintColor ?? .label
      textNode.textColor = safeColor
      borderColor = safeColor.cgColor
      imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(safeColor)
      imageNode.setNeedsDisplay()
    }
  }

  var disabledAlpha: CGFloat = 0.7 {
    didSet {
      if !isEnabled {
        alpha = disabledAlpha
      }
    }
  }

  var font: UIFont {
    get {
      return textNode.font
    }
    set {
      textNode.font = newValue
      setNeedsLayout()
    }
  }
  
  var title: String? {
    get {
      return textNode.text
    }
    set {
      textNode.text = newValue
      setNeedsLayout()
    }
  }

  var truncateMode: NSLineBreakMode {
    get {
      return textNode.truncationMode
    }
    set {
      textNode.truncationMode = newValue
      setNeedsLayout()
    }
  }

  var image: UIImage? {
    get {
      return imageNode.image
    }
    set {
      imageNode.image = newValue
      setNeedsLayout()
    }
  }

  var insetPadding: UIEdgeInsets = .zero
  
  private let disposeBag = DisposeBag()

  private let textNode: TextNode
  private let imageNode = ASImageNode().then {
    $0.style.flexShrink = 1
  }
  
  init(image: UIImage? = nil, text: String? = nil, weight: FontWeight = .regular, size: FontSize = .default, color: UIColor = .label) {
    imageNode.image = image
    
    textNode = TextNode(weight: weight, size: size, color: color)
    textNode.text = text

    super.init()
    commonInit()

    tintColor = color
  }

  fileprivate func commonInit() {
    automaticallyManagesSubnodes = true

    textNode.style.flexShrink = 1

    isUserInteractionEnabled = true
    textNode.maximumNumberOfLines = 1
    imageNode.contentMode = .scaleAspectFit
    backgroundColor = .clear

    setupBindings()
  }


  private func setupBindings() {

    FontSettings.shared.fontSizeObserver
      .map { CGSize(square: $0) }
      .bind(to: imageNode.rx.preferredSize)
      .disposed(by: disposeBag)

  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = []
    if imageNode.image != nil {
      horizontal.children?.append(imageNode)
    }
    if textNode.text.isNotNilOrEmpty {
      horizontal.children?.append(textNode)
    }
    horizontal.spacing = 4
    horizontal.verticalAlignment = .center

    let inset = ASInsetLayoutSpec()
    inset.child = horizontal
    inset.insets = insetPadding

    return inset
  }

}
