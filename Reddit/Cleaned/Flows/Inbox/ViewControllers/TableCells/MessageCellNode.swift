//
//  MessageCellNode.swift
//  Reddit
//
//  Created by made2k on 1/28/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI
import RxSwift

final class MessageCellNode: SwipableCellNode {

  // MARK: Subnodes

  private let iconNode: ASImageNode = ASImageNode().then {
    $0.contentMode = .scaleAspectFit
    $0.style.preferredSize = CGSize(square: 20)
  }

  private let titleNode: TextNode = TextNode(weight: .semibold)
  private let bodyNode: DTCoreTextNode = DTCoreTextNode(color: .secondaryLabel)
  let dateNode: TextNode = TextNode(color: .secondaryLabel)

  private let authorButton: ButtonNode = ButtonNode(weight: .bold, color: .secondaryLabel)
  private let inTextNode: TextNode = TextNode(color: .secondaryLabel)
  private let subredditButton: ButtonNode = ButtonNode(weight: .bold, color: .secondaryLabel)
  private let actionButton: ButtonNode = ButtonNode(image: R.image.icon_ellipsis(), color: .secondaryLabel)

  // MARK: Properties

  let model: MessageModel
  private(set) weak var delegate: MessageCellNodeDelegate?
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  init(model: MessageModel, delegate: MessageCellNodeDelegate) {
    self.model = model
    self.delegate = delegate

    super.init()

    automaticallyManagesSubnodes = true
    selectionStyle = .none

    bodyNode.delegate = self

    staticSetup()
    setupBindings()
  }

  // MARK: - Bindings

  private func staticSetup() {

    authorButton.title = model.message.author
    subredditButton.title = model.message.subreddit
    bodyNode.html = model.message.bodyHtml
    dateNode.text = model.message.created.timeAgo
    inTextNode.text = "in"

    if model.message.kind == .message {
      iconNode.image = R.image.icon_mail_filled()

    } else {
      if model.message.parentType == DataKind.link {
        iconNode.image = R.image.icon_listing()

      } else {
        iconNode.image = R.image.icon_chat_bubble_filled()
      }
    }
    iconNode.image = iconNode.image?.withRenderingMode(.alwaysTemplate)

    // subject
    if
      let type = model.message.parentType,
      let subreddit = model.message.subreddit,
      model.message.kind == .comment {

      let typeString: String = type == .link ? "post" : "comment"
      titleNode.text = "u/\(model.message.author) replied to your \(typeString) in r/\(subreddit)"

    } else {
      titleNode.text = model.message.subject
    }

  }

  private func setupBindings() {

    rx.didEnterVisibleState
      .take(1)
      .subscribe(onNext: { [model] in
        model.markRead().cauterize()

      }).disposed(by: disposeBag)

    model.readObserver
      .map { (read: Bool) -> UIColor in
        read ?
          .systemBackground :
          R.color.highlightBackground().unsafelyUnwrapped
      }
      .bind(to: rx.backgroundColor)
      .disposed(by: disposeBag)

    model.readObserver
      .map { (read: Bool) -> UIColor in
        read ?
          .tertiaryLabel :
          .systemBlue
      }
      .bind(to: iconNode.rx.imageTintColor)
      .disposed(by: disposeBag)

    actionButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        guard let indexPath = self.indexPath else { return }
        self.delegate?.messageCellShowActions(for: self.model, indexPath: indexPath)

      }).disposed(by: disposeBag)

    authorButton.rx.tap
      .subscribe(onNext: { [unowned self] in
        LinkHandler.openRedditUser(userName: self.model.message.author)

      }).disposed(by: disposeBag)

    Observable.combineLatest(Settings.swipeMode, Settings.swipeManifest)
      .filter { $0.0 } // Swipe must be enabled
      .map { $0.1.message }
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

  // MARK: - Layout

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let authorSubSpec = ASStackLayoutSpec.horizontal()
    authorSubSpec.children = [authorButton]
    if model.message.subreddit != nil {
      authorSubSpec.children?.append(contentsOf: [inTextNode, subredditButton])
    }
    authorSubSpec.flexWrap = .wrap
    authorSubSpec.spacing = 4

    let actionTimeSpec = ASStackLayoutSpec.horizontal()
    actionTimeSpec.children = [actionButton, dateNode]
    actionTimeSpec.spacing = 8

    let bottomHorizontalSpec = ASStackLayoutSpec.horizontal()
    bottomHorizontalSpec.children = [authorSubSpec, ASLayoutSpec.spacer(), actionTimeSpec]
    bottomHorizontalSpec.spacing = 6
    bottomHorizontalSpec.style.flexShrink = 1
    bottomHorizontalSpec.flexWrap = .wrap

    let contentVerticalSpec = ASStackLayoutSpec.vertical()
    contentVerticalSpec.children = [titleNode, bodyNode, bottomHorizontalSpec]
    contentVerticalSpec.spacing = 12
    contentVerticalSpec.style.flexShrink = 1

    let contentHorizontalSpec = ASStackLayoutSpec.horizontal()
    contentHorizontalSpec.children = [iconNode, contentVerticalSpec]
    contentHorizontalSpec.spacing = 8
    contentHorizontalSpec.style.flexShrink = 1

    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = contentHorizontalSpec
    insetSpec.insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    insetSpec.style.flexShrink = 1

    return insetSpec
  }

}

extension MessageCellNode: ASTextNodeDelegate {

  func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
    if let url = value as? URL {
      LinkHandler.handleUrl(url)
    }
  }

}
