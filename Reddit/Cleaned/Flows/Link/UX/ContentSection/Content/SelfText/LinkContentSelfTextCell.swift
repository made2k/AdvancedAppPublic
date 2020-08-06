//
//  SelfLinkCell.swift
//  Reddit
//
//  Created by made2k on 10/28/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit
import DTCoreText
import RedditAPI
import RxCocoa
import RxSwift
import Then

/**
 A cell that displays self text.
 */
class LinkContentSelfTextCell: ASCellNode {

  let model: LinkModel
  private let textNode = DTCoreTextNode().then {
    $0.textColor = .label
    $0.lineHeightMultiple = 1.6
    $0.isUserInteractionEnabled = true
    $0.style.flexShrink = 1
  }
  private var gradientNode: GradientDisplayNode {
    let backgroundColor = self.backgroundColor ?? .black
    let colors = [
      backgroundColor.withAlphaComponent(0),
      backgroundColor.withAlphaComponent(0.8),
      backgroundColor
    ]
    
    let node = GradientDisplayNode(colors: colors)
    node.style.height = ASDimension(unit: .points, value: collapsedHeight)
    return node
  }
  
  // Simply just forward the delegate
  weak var textDelegate: ASTextNodeDelegate? {
    get { return textNode.delegate }
    set { textNode.delegate = newValue }
  }

  // Collapse layout adjustments
  private var adjustmentIndex: IndexPath?
  private let didLayout = ReplaySubject<Void>.create(bufferSize: 0)
  
  private let collapsedHeight: CGFloat = 80
  
  private var isCollapsed = false {
    didSet {
      let height = isCollapsed ? collapsedHeight : .infinity
      textNode.style.maxHeight = ASDimension(unit: .points, value: height)
      textNode.setNeedsLayout()
    }
  }
  private var contextMenu: SelfTextContextMenu?
  private(set) weak var delegate: LinkContentSelfTextCellDelegate?
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  init (linkModel: LinkModel, delegate: LinkContentSelfTextCellDelegate) {
    self.model = linkModel
    self.delegate = delegate
    
    super.init()
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    
    backgroundColor = .systemBackground

    setupBindings()
  }

  // MARK: - Lifecycle

  override func didLoad() {
    super.didLoad()
    
    if #available(iOS 13.0, *) {
      contextMenu = SelfTextContextMenu(model: model, delegate: self)
      contextMenu?.register(view: view)

    } else {
      setupLongPressGesture()
    }
  }

  override func layoutDidFinish() {
    super.layoutDidFinish()
    didLayout.onNext(())
  }

  // MARK: - Bindings
  
  private func setupBindings() {

    // TODO: Reevaluate a way to do this
    didLayout
      .map { [unowned self] _ in self.adjustmentIndex }
      .filterNil()
      .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [unowned self] in
        self.adjustmentIndex = nil
        self.tableNode?.scrollToRow(at: $0, at: .none, animated: false)
      }).disposed(by: disposeBag)

    model.selfText
      .take(1)
      .subscribe(onNext: { [weak self] in
        self?.textNode.html = $0
      })
      .disposed(by: disposeBag)

    model.selfText
      .skip(1)
      .subscribe(onNext: { [weak self] in
        self?.textNode.html = $0
        self?.textNode.setNeedsLayout()
        self?.setNeedsLayout()
      })
      .disposed(by: disposeBag)

  }

  // MARK: - Gesture
  
  private func setupLongPressGesture() {
    let recognizer = UILongPressGestureRecognizer { [weak delegate, weak model] gesture in
      guard gesture.state == .began else { return }
      guard let model = model else { return }
      delegate?.selfTextWasLongPressed(model)
    }
    recognizer.cancelsTouchesInView = true
    
    view.addGestureRecognizer(recognizer)
  }
  
  // MARK: - Layout
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let insetSpec = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
      child: textNode)
    
    // Show the gradient fade when collapsed.
    if isCollapsed {
      let overlay = ASOverlayLayoutSpec(child: insetSpec, overlay: gradientNode)
      return overlay
    }
    
    return insetSpec
  }
  
  func toggleCollapsed() {
    if isCollapsed == false {
      guard textNode.bounds.height > collapsedHeight + 30 else { return }
    }
    
    let isCollapsing = isCollapsed == false
    let isTopOffscreen: Bool
    if let window = UIApplication.shared.activeWindow() {
      isTopOffscreen = view.convert(bounds, to: window).origin.y < 50
    } else {
      isTopOffscreen = false
    }

    if isCollapsing && isTopOffscreen {
      adjustmentIndex = indexPath
    }
    
    isCollapsed = !isCollapsed
    setNeedsLayout()
  }

}
