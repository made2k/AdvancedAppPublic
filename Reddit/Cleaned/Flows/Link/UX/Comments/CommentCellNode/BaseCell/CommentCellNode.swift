//
//  CommentCellNode.swift
//  Reddit
//
//  Created by made2k on 10/27/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI
import RxSwift
import Then
import UIKit

class CommentCellNode: SwipableCellNode {

  // MARK: - Static Helpers
  
  static func colorForLevel(_ level: Int) -> UIColor {
    let colorKey = Settings.commentIndexTheme
    let colors: [UIColor] = CommentIndicatorTheme.themes[colorKey]!.map { UIColor(hex: $0) }
    
    if level > 0 {
      return colors[(level - 1) % colors.count]
    }
    
    return .clear
  }

  // MARK: - Subnodes

  let detailNode: CommentInfoNode?
  let gildingNode: GildingNode?

  lazy var childrenText: TextNode = {
    return TextNode(size: .micro, color: .secondaryLabel).then {
      let children = commentModel?.children.count ?? 0
      $0.text = children == 1 ?
        "1 child" :
        "\(children) children"
    }
  }()

  // TODO: Subclasses, I'd like to keep these private
  lazy var levelIndicator: ASDisplayNode = {
    return ASDisplayNode().then {
      let indicatorSize: CGFloat = 2.25
      $0.style.width = ASDimensionMake(indicatorSize)
      $0.backgroundColor = CommentCellNode.colorForLevel(model.level)
      $0.cornerRadius = indicatorSize / 2
    }
  }()

  lazy var bodyText: DTCoreTextNode = {
    return DTCoreTextNode().then {
      $0.textColor = .label
      $0.lineHeightMultiple = 1.6
      $0.html = model.bodyHtml
      $0.isUserInteractionEnabled = true
      $0.passthroughNonlinkTouches = true
    }
  }()

  lazy var loadMoreText: TextNode = {
    return TextNode().then {
      $0.textColor = .label
      $0.text = model.body
    }
  }()
  lazy var loadMoreLoadingNode: ASDisplayNode = {
    let node = ASDisplayNode(viewBlock: { () -> UIView in
      let activity = ThemedUIActivityIndicatorView(style: .large)
      return activity
    })
    node.style.preferredLayoutSize = ASLayoutSize(
      width: ASDimension(unit: .points, value: 25),
      height: ASDimension(unit: .points, value: 25))
    return node
  }()

  let seperator = ColorNode(backgroundColor: .separator).then {
    $0.style.height = ASDimension(unit: .points, value: 1)
    $0.alpha = 0.7
  }

  let replyButton = ButtonNode(image: R.image.icon_reply(), color: .secondaryLabel).then {
    $0.insetPadding = UIEdgeInsets(inset: 2)
    $0.hitTestSlop = UIEdgeInsets(inset: -5)
  }
  lazy var upvoteButton: UpvoteButtonNode = {
    let node = UpvoteButtonNode(
      model: commentModel.unsafelyUnwrapped,
      defaultColor: .secondaryLabel
    )
    node.hitTestSlop = UIEdgeInsets(inset: -5)
    return node
  }()
  lazy var downvoteButton: DownvoteButtonNode = {
    let node = DownvoteButtonNode(
      model: commentModel.unsafelyUnwrapped,
      defaultColor: .secondaryLabel
    )
    node.hitTestSlop = UIEdgeInsets(inset: -5)
    return node
  }()

  // MARK: - Properties
  
  /// Forwards the text delegate to the text node
  weak var textDelegate: ASTextNodeDelegate? {
    get { return bodyText.delegate }
    set { bodyText.delegate = newValue }
  }
  
  private var contextMenu: CommentContextMenu?
  private weak var delegate: CommentContextMenuDelegate?
  
  var longPressed: (() -> Void)? = nil
  var replyAction: (() -> Void)? = nil
  
  var isFocused: Bool = false {
    didSet {
      backgroundColor = isFocused ?
        R.color.focusedBackground() :
        .systemBackground
    }
  }
  
  private let disposeBag = DisposeBag()
  
  let model: CommentModelType
  var commentModel: CommentModel? { return model as? CommentModel }
  var moreModel: MoreModel? { return model as? MoreModel }
  
  // MARK: - Node setup
  
  var showVoteButtons: Bool = true
  var showMessageBody: Bool = true
  var showLevel: Bool = true
  var showSeparator: Bool = true
  var showChildren: Bool = false
  var isHiddenState: Bool = false
  
  // MARK: - Initialization
  
  init(model: CommentModelType, link: Link?, delegate: CommentContextMenuDelegate? = nil) {
    self.model = model
    self.delegate = delegate

    if let comment = model as? CommentModel {
      detailNode = CommentInfoNode(comment: comment, link: link)
      gildingNode = GildingNode(gildings: comment.comment.gildings)
    } else {
      detailNode = nil
      gildingNode = nil
    }

    // TODO: Remove star icon from assets
    
    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    backgroundColor = isFocused ?
      R.color.focusedBackground() :
      .systemBackground

    replyButton.tapAction = { [weak self] in
      self?.replyAction?()
    }
    
    setupBindings()
  }
  
  private func setupBindings() {

    guard let model = commentModel else { return }

    let initialSize = CGSize(square: FontSettings.shared.fontMultiplier.value * 21)
    replyButton.style.preferredSize = initialSize
    upvoteButton.style.preferredSize = initialSize
    downvoteButton.style.preferredSize = initialSize
    
    let buttonSize = FontSettings.shared.fontMultiplier
      .map { $0 * 19 }
      .share(replay: 1)
    
    buttonSize
      .skip(1)
      .map { CGSize(square: $0) }
      .bind(to: replyButton.rx.preferredSize)
      .disposed(by: disposeBag)
    
    buttonSize
      .skip(1)
      .subscribe(onNext: { [unowned self] in
          self.upvoteButton.setSize($0)
          self.downvoteButton.setSize($0)
      }).disposed(by: disposeBag)

    model.bodyHtmlObserver
      .skip(1)
      .bind(to: bodyText.rx.html, setNeedsLayout: self)
      .disposed(by: disposeBag)
    
    Observable.combineLatest(Settings.swipeMode, Settings.swipeHidesCommentActions)
      .asVoid()
      .skip(1)
      .subscribe(onNext: { [unowned self] _ in
        self.setNeedsLayout()
      }).disposed(by: disposeBag)

  }

  private func didLoadBindings() {

    Observable.combineLatest(Settings.swipeMode, Settings.swipeManifest)
      .filter { $0.0 } // Swipe must be enabled
      .map { $0.1.comment }
      .subscribeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [unowned self] in
        self.registerTriggers($0)
      }).disposed(by: disposeBag)

    Observable.combineLatest(Settings.swipeMode, Settings.swipeManifest)
      .filter { $0.0 == false } // Swipe must be disabled
      .subscribeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [unowned self] _ in
        self.clearTriggers()
      }).disposed(by: disposeBag)

  }
  
  override func didLoad() {
    super.didLoad()
    
    // Do this after we attempt to setup the context menu
    defer { addLongPressGesture() }
    
    guard let model = model as? CommentModel else { return }
    guard let delegate = delegate else { return }
    
    contextMenu = CommentContextMenu(model: model, sourceView: view, delegate: delegate)
    contextMenu?.register(view: view)

    didLoadBindings()
  }
  
  private func addLongPressGesture() {
    guard longPressed != nil && contextMenu == nil else { return }
    
    let recognizer = UILongPressGestureRecognizer { [weak self] recognizer in
      guard recognizer.state == .began else { return }
      self?.longPressed?()
    }
    recognizer.cancelsTouchesInView = true
    view.addGestureRecognizer(recognizer)
  }
  
}

