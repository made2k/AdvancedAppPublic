//
//  LiveCommentEntryNode.swift
//  Reddit
//
//  Created by made2k on 9/3/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit
import RxCocoa_Texture
import RxSwift

final class LiveCommentEntryNode: ASDisplayNode {

  private let textNode = ThemeableEditableTextNode(textColor: .label, backgroundColor: .systemBackground).then {
    $0.lineHeightMultiple = 1
    $0.font = Settings.fontSettings.fontValue
    $0.borderColor = UIColor.separator.cgColor
    $0.borderWidth = 1
    $0.backgroundColor = .systemBackground
    $0.cornerRadius = 20
    $0.clipsToBounds = true
    $0.placeholderText = "Reply with a new comment."
    $0.style.flexGrow = 1
    $0.style.flexShrink = 1
  }
  private let buttonNode = ASButtonNode().then {
    $0.backgroundColor = UIColor(hex: "3a88f0")
    $0.style.preferredSize = CGSize(width: 30, height: 30)
    $0.cornerRadius = 15
    $0.setBackgroundImage(R.image.icon_small_uparrow(), for: .normal)
    $0.backgroundImageNode.style.height = ASDimension(unit: .fraction, value: 0.7)
    $0.backgroundImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(.white)
  }
  private let detailNode = TextNode(size: .micro, color: .secondaryLabel)

  private let delegate: LiveCommentViewControllerDelegate
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  init(delegate: LiveCommentViewControllerDelegate) {

    self.delegate = delegate

    super.init()

    automaticallyManagesSubnodes = true
    automaticallyRelayoutOnSafeAreaChanges = true
    backgroundColor = .secondarySystemBackground

    updateHeight()

    textNode.style.maxHeight = ASDimension(unit: .points, value: textNode.style.height.value * 3)

    textNode.delegate = self

    setupBindings()
  }

  // MARK: - Lifecycle

  override func didLoad() {
    super.didLoad()
    textNode.textView.alwaysBounceVertical = false
  }

  override func layoutDidFinish() {
    super.layoutDidFinish()
    textNode.textView.keyboardDistanceFromTextField = detailNode.calculatedSize.height + 5
  }

  // MARK: - Bindings

  private func setupBindings() {

    delegate.replyText
      .bind(to: detailNode.rx.text)
      .disposed(by: disposeBag)

    buttonNode.rx.tap
      .subscribe(onNext: { [unowned self] in
        self.buttonPressed()
      }).disposed(by: disposeBag)

  }

  // MARK: - Layout

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [textNode, buttonNode]
    horizontal.verticalAlignment = .bottom
    horizontal.spacing = 12

    let vertical = ASStackLayoutSpec.vertical()
    vertical.children = [horizontal]
    if detailNode.text.isNotNilOrEmpty {
      let detailInset = ASInsetLayoutSpec()
      detailInset.child = detailNode
      detailInset.insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
      vertical.children?.append(detailInset)
    }

    let inset = ASInsetLayoutSpec()
    inset.child = vertical
    inset.insets = UIEdgeInsets(top: 8 + safeAreaInsets.top,
                                left: 16 + safeAreaInsets.left,
                                bottom: 8 + safeAreaInsets.bottom,
                                right: 16 + safeAreaInsets.right)

    return inset
  }

  // MARK: - Actions

  private func buttonPressed() {
    guard let text = textNode.text, !text.isEmpty else { return }

    textNode.text = nil
    updateHeight()
    textNode.resignFirstResponder()

    firstly {
      return delegate.didReply(with: text)

    }.catch { _ in
      self.textNode.text = text
      self.updateHeight()
      self.textNode.becomeFirstResponder()
    }

  }

  // MARK: - Helpers

  private func updateHeight() {
    let constrainedSize = CGSize(width: textNode.calculatedSize.width, height: .greatestFiniteMagnitude)
    let height = textNode.textView.sizeThatFits(constrainedSize).height

    if height != textNode.calculatedSize.height {
      self.textNode.style.height = ASDimension(unit: .points, value: height)
      self.textNode.cornerRadius = min(20, height / 2)
      self.setNeedsLayout()
    }
  }

}

extension LiveCommentEntryNode: ASEditableTextNodeDelegate {

  func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
    updateHeight()
  }
}
