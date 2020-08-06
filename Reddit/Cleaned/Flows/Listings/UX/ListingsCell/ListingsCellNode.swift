//
//  ListingsCellNode.swift
//  Reddit
//
//  Created by made2k on 1/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Logging
import RedditAPI
import RxSwift

class ListingsCellNode: SwipableCellNode {

  // MARK: - Subnodes

  lazy var titleTextNode: TextNode = {
    TextNode().then {
      $0.text = model.link.title
      $0.lineHeightMultiple = 1.2
      $0.style.flexShrink = 1
    }
  }()
  lazy var domainTextNode: TextNode = {
    TextNode(size: .micro, color: .secondaryLabel).then {
      $0.text = model.link.domain
      $0.style.flexGrow = 1
    }
  }()

  private let upvoteButtonNode: VoteButtonNode
  private let downvoteButtonNode: VoteButtonNode
  private(set) lazy var voteButtonSpec: ASLayoutSpec = {
    let vertical = ASStackLayoutSpec.vertical()
    if link.archived == false {
      vertical.children = [upvoteButtonNode, downvoteButtonNode]
    }
    return vertical
  }()

  private lazy var nsfwTextNode: RoundedTextNode = {
    RoundedTextNode(size: .micro, color: R.color.nsfwText().unsafelyUnwrapped).then {
      $0.textContainerInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
      $0.text = "NSFW"
      $0.backgroundColor = R.color.nsfwBackground()
      $0.lineHeightMultiple = 1
      $0.maximumNumberOfLines = 1
      $0.clipsToBounds = true
    }
  }()
  private let flairNode: FlairNode?
  private(set) lazy var nsfwFlairSpec: ASLayoutSpec? = {
    guard model.link.over18 || model.link.flair?.text != nil else { return nil }

    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = []
    horizontal.spacing = 8
    horizontal.verticalAlignment = .center

    if model.link.over18 {
      horizontal.children?.append(nsfwTextNode)
    }
    if let flairNode = flairNode {
      horizontal.children?.append(flairNode)
    }
    return horizontal
  }()

  private let scoreTextNode: ScoreTextNode
  private let commentTextNode: CommentCountTextNode
  private let ageTextNode = ImageTextNode(image: R.image.icon_time().unsafelyUnwrapped, textColor: .secondaryLabel)
  private let subredditButtonNode: SubredditButtonNode
  private let gildingNode: GildingNode
  private(set) lazy var bottomDetailSpec: ASLayoutSpec = {
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.spacing = 8
    horizontal.verticalAlignment = .center
    horizontal.style.flexShrink = 1

    horizontal.children = [
      scoreTextNode,
      commentTextNode,
      ageTextNode
    ]

    if gildingNode.hasBeenGilded {
      horizontal.children?.prepend(gildingNode)
    }

    horizontal.children?.append(contentsOf: [ASLayoutSpec.spacer(), subredditButtonNode])
    return horizontal
  }()

  // MARK: - Properties

  let model: LinkModel
  var link: Link { return model.link }
  private(set) weak var delegate: ListingsCellDelegate?
  private var contextMenu: ContextMenu?
  private var longPressGesture: UILongPressGestureRecognizer?
  private(set) var disposeBag = DisposeBag()

  // MARK: - Init

  init(model: LinkModel, delegate: ListingsCellDelegate?) {
    self.model = model
    self.delegate = delegate
    
    if let flair = model.link.flair {
      flairNode = FlairNode(flair: flair, type: .link, size: .micro, textColor: .secondaryLabel)

    } else {
      flairNode = nil
    }
    
    upvoteButtonNode = UpvoteButtonNode(
      model: model,
      defaultColor: .secondaryLabel).then {
        $0.insets = 6
    }
    downvoteButtonNode = DownvoteButtonNode(
      model: model,
      defaultColor: .secondaryLabel).then {
        $0.insets = 6
    }

    scoreTextNode = ScoreTextNode(score: model.link.score)
    commentTextNode = CommentCountTextNode(commentCount: model.link.commentCount)
    subredditButtonNode = SubredditButtonNode(subreddit: model.link.subreddit).then {
      $0.style.flexShrink = 1
      $0.truncateMode = .byTruncatingTail
    }

    gildingNode = GildingNode(gildings: model.link.gildings)

    super.init()
    automaticallyManagesSubnodes = true

    backgroundColor = .systemBackground
    selectionStyle = .none

    setupBindings()
  }

  // MARK: - Lifecycle

  override func didLoad() {
    super.didLoad()
    setupContextGesture()
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
  
  func setupBindings() {

    model.readObserver
      .distinctUntilChanged()
      .map { (read: Bool) -> UIColor in
        read ? .secondaryLabel : .label
      }
      .bind(to: titleTextNode.rx.textColor)
      .disposed(by: disposeBag)

    model.scoreTextObserver
      .bind(to: scoreTextNode.rx.text)
      .disposed(by: disposeBag)

    ageTextNode.setText(model.link.created.timeAgo)

    FontSettings.shared.fontMultiplier
      .map { $0 * 28 }
      .filter { [weak self] newSize in
        guard let self = self else { return false }
        return newSize != self.upvoteButtonNode.style.preferredSize.width
      }
      .subscribe(onNext: { [weak self] (size: CGFloat) in
        self?.upvoteButtonNode.setSize(size)
        self?.downvoteButtonNode.setSize(size)
      }).disposed(by: disposeBag)

    Observable.combineLatest(Settings.swipeMode, Settings.swipeManifest)
      .filter { $0.0 } // Swipe must be enabled
      .map { $0.1.listing }
      .subscribeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] in
        self?.registerTriggers($0)
      }).disposed(by: disposeBag)

    Observable.combineLatest(Settings.swipeMode, Settings.swipeManifest)
      .filter { $0.0 == false } // Swipe must be disabled
      .subscribeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [weak self] _ in
        self?.clearTriggers()
      }).disposed(by: disposeBag)

  }
  
  private func setupContextGesture() {
    guard let delegate = delegate else { return }

    let sourceView = getSourceViewForContextMenu()

    let contextMenu = ListingContextMenu(model: model, sourceView: sourceView, delegate: delegate)
    contextMenu?.register(view: view)

    self.contextMenu = contextMenu
  }
  
  /**
   Based on the media type, the source view will differ.
   If the media type is an image, we'll display from the preview or thumbnail.
   Otherwise we'll show from nothing and use the entire cell.
   */
  private func getSourceViewForContextMenu() -> UIView? {
    
    // Using a switch to capture any types that may change
    switch model.linkType {
    case .selfText, .video, .article, .unknown:
      return nil
    case .image:
      break
    }

    if let preview = self as? PreviewListingsCellNode, preview.previewNode.isMediaEnabled {
      return preview.previewNode.view

    } else if let thumbnail = self as? ThumbnailListingsCellNode, thumbnail.hasThumbnail {
      return thumbnail.thumbnailNode.view

    } else {
      return nil
    }

  }

  // Reset the gestures setup. This can happen if thumbnails are removed
  func resetContextGesture() {
    longPressGesture?.removeFromView()
    longPressGesture = nil
    contextMenu = nil

    setupContextGesture()
   }
  
  // MARK: - Layout

  func createSeparator() -> ASDisplayNode {
    let node = ColorNode(backgroundColor: .separator)
    node.style.height = ASDimension(unit: .points, value: 1)
    node.alpha = 0.7
    return node
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    #if DEBUG
    fatalError("LayoutSpec must be overridden by subclass")
    #else
    log.error("LayoutSpec must be overridden by subclass")
    return ASLayoutSpec()
    #endif
  }

}
