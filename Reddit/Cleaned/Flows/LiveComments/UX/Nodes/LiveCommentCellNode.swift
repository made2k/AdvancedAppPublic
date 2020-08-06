//
//  LiveCommentCellNode.swift
//  Reddit
//
//  Created by made2k on 9/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI
import RxSwift
import Then

class LiveCommentCellNode: ASCellNode {

  private static let detailFontSize: CGFloat = 11
  private static let voteButtonSize: CGFloat = 25

  // MARK: - Node elements

  private let authorButton = ButtonNode(size: .micro)
  private let detailText = TextNode(size: .micro, color: .secondaryLabel).then {
    $0.style.flexShrink = 1
    $0.maximumNumberOfLines = 1
  }
  private let bodyText = DTCoreTextNode().then {
    $0.lineHeightMultiple = 1.6
    $0.isUserInteractionEnabled = true
    $0.passthroughNonlinkTouches = true
  }
  private let upvoteButton: UpvoteButtonNode
  private let downvoteButton: DownvoteButtonNode
  private let levelIndicator = ASDisplayNode().then {
    $0.style.width = ASDimension(unit: .points, value: 2.25)
    $0.cornerRadius = 2.25 / 2
  }

  // MARK: - Properties

  override var isSelected: Bool {
    didSet {
      guard AccountModel.currentAccount.value.isSignedIn else { return }
      backgroundColor = isSelected ?
        R.color.focusedBackground() :
        .systemBackground
    }
  }

  private let model: CommentModel
  private var updateTimer: Timer?
  private let disposeBag = DisposeBag()

  
  /// Create a cell node representing a live comment.
  ///
  /// - Parameters:
  ///   - model: The comment model to display.
  ///   - link: The link used to parse author formatting.
  init(model: CommentModel, link: Link?) {

    self.model = model

    upvoteButton = UpvoteButtonNode(model: model, defaultColor: .secondaryLabel)
    upvoteButton.setSize(LiveCommentCellNode.voteButtonSize)

    downvoteButton = DownvoteButtonNode(model: model, defaultColor: .secondaryLabel)
    downvoteButton.setSize(LiveCommentCellNode.voteButtonSize)

    levelIndicator.backgroundColor = CommentCellNode.colorForLevel(model.level)

    super.init()

    automaticallyManagesSubnodes = true
    selectionStyle = .none

    backgroundColor = .systemBackground

    bodyText.delegate = self

    setupBindings()
  }

  override func didEnterVisibleState() {
    super.didEnterVisibleState()

    updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
      self.detailText.text = " • \(self.model.comment.created.timeAgo)"
    }
  }

  override func didExitVisibleState() {
    super.didExitVisibleState()

    updateTimer?.invalidate()
    updateTimer = nil
  }

  // MARK: - Bindings

  private func setupBindings() {
    
    model.authorTextObserver
      .bind(to: authorButton.rx.title)
      .disposed(by: disposeBag)

    model.distinguishedColor
      .replaceNilWith(.secondaryLabel)
      .bind(to: authorButton.rx.tintColor)
      .disposed(by: disposeBag)

    model.ageText
      .map { " • \($0)" }
      .bind(to: detailText.rx.text)
      .disposed(by: disposeBag)

    model.bodyHtmlObserver
      .bind(to: bodyText.rx.html)
      .disposed(by: disposeBag)

  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let detailSpec = ASStackLayoutSpec.horizontal()
    detailSpec.verticalAlignment = .bottom
    detailSpec.style.flexShrink = 1
    detailSpec.children = [authorButton, detailText]

    let actionSpec = ASStackLayoutSpec.horizontal()
    actionSpec.spacing = 8
    if model.archived == false {
      actionSpec.children = [ASLayoutSpec.spacer(), upvoteButton, downvoteButton]
    }

    let detailBodySpec = ASStackLayoutSpec.vertical()
    detailBodySpec.spacing = 8
    detailBodySpec.style.flexShrink = 1
    detailBodySpec.children = [detailSpec, bodyText]

    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [detailBodySpec]
    horizontal.spacing = 12
    horizontal.style.flexShrink = 1
    if model.level > 0 {
      horizontal.children?.insert(levelIndicator, at: 0)
    }

    let bodyActionSpec = ASStackLayoutSpec.vertical()
    bodyActionSpec.children = [horizontal]
    bodyActionSpec.spacing = 12
    bodyActionSpec.style.flexShrink = 1
    if AccountModel.currentAccount.value.isSignedIn {
      bodyActionSpec.children?.append(actionSpec)
    }

    let inset = ASInsetLayoutSpec()
    inset.child = bodyActionSpec
    inset.insets = UIEdgeInsets(top: 8, left: 16 + (8 * CGFloat(model.level)), bottom: 8, right: 16)
    inset.style.flexShrink = 1

    return inset
  }
}

extension LiveCommentCellNode: ASTextNodeDelegate {

  func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
    guard let url = value as? URL else { return }

    if url.absoluteString.hasPrefix("/r/") || url.absoluteString.hasPrefix("/u/") {
      guard let url = URL(string: "https://www.reddit.com\(url.absoluteString)") else { return }
      OpenInPreference.shared.openBrowser(url: url)

    } else {
      OpenInPreference.shared.openBrowser(url: url)
    }
  }
}
