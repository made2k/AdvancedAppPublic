//
//  ImageTextNode.swift
//  Reddit
//
//  Created by made2k on 2/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RxSwift
import RxCocoa

class ImageTextNode: ASDisplayNode {
  private let imageNode: ASImageNode
  private let textNode: TextNode

  private var disposeBag = DisposeBag()
  
  init(image: UIImage, weight: FontWeight = .regular, size: FontSize = .default, textColor: UIColor = .label) {

    imageNode = ASImageNode()
    imageNode.image = image
    imageNode.contentMode = .scaleAspectFit
    imageNode.tintColor = textColor

    textNode = TextNode(weight: weight, size: size, color: textColor)

    imageNode.style.flexShrink = 1
    imageNode.style.flexGrow = 1
    
    super.init()

    automaticallyManagesSubnodes = true

    let size = CGSize(square: textNode.font.pointSize * 0.8)
    imageNode.style.preferredSize = size
  }

  override func didEnterPreloadState() {
    super.didEnterPreloadState()
    setupBindings()
  }

  override func didExitPreloadState() {
    super.didExitPreloadState()
    disposeBag = DisposeBag()
  }
  
  private func setupBindings() {

    textNode.fontObserver
      .map(\.pointSize)
      .map { $0 * 0.8 }
      .map { CGSize(square: $0) }
      .filter { [unowned self] newSize in
        return newSize != self.imageNode.style.preferredSize
      }
      .bind(to: imageNode.rx.preferredSize, setNeedsLayout: self)
      .disposed(by: disposeBag)

  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.alignItems = .baselineLast
    horizontal.children = [imageNode, textNode]
    horizontal.spacing = 3

    return horizontal
  }
  
  func setText(_ text: String?) {
    textNode.text = text
  }
}

extension Reactive where Base: ImageTextNode {

  var text: Binder<String?> {
    return Binder(self.base) { node, text in
      node.setText(text)
    }
  }

}
