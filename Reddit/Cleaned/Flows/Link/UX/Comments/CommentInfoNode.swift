//
//  CommentInfoNode.swift
//  Reddit
//
//  Created by made2k on 1/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI
import RxCocoa
import RxSwift
import Then

class CommentInfoNode: ASDisplayNode {

  private let authorAgeSeparator = TextNode(size: .micro, color: .secondaryLabel).then {
    $0.text = " • "
    $0.maximumNumberOfLines = 1
  }
  private let ageScoreSeparator = TextNode(size: .micro, color: .secondaryLabel).then {
    $0.text = " • "
    $0.maximumNumberOfLines = 1
  }
  private let scoreFlairSeparator = TextNode(size: .micro, color: .secondaryLabel).then {
    $0.text = " • "
    $0.maximumNumberOfLines = 1
  }
  private let swipeVoteIndicator = ASImageNode().then {
    $0.style.flexShrink = 1
    $0.contentMode = .scaleAspectFit
    $0.style.preferredSize = CGSize(square: 12)
  }

  private let authorButton = ButtonNode(size :.micro, color: .secondaryLabel)
  private let ageNode = TextNode(size: .micro, color: .secondaryLabel).then {
    $0.maximumNumberOfLines = 1
  }
  private let scoreNode = TextNode(size: .micro, color: .secondaryLabel).then {
    $0.maximumNumberOfLines = 1
  }
  private let flairNode: FlairNode?

  private let comment: CommentModel
  private let link: Link?
  
  private let userContext: UserPreviewContextMenu?

  private var disposeBag = DisposeBag()
  
  init(comment: CommentModel, link: Link?) {
    self.comment = comment
    self.link = link
    
    if let flair = comment.comment.flair {
      flairNode = FlairNode(flair: flair, type: .comment, size: .micro, textColor: .secondaryLabel)
    } else {
      flairNode = nil
    }
    
    if comment.isDeleted {
      userContext = nil
      
    } else {
      userContext = UserPreviewContextMenu(username: comment.author)
    }

    super.init()

    automaticallyManagesSubnodes = true
    style.flexShrink = 1

    authorButton.title = comment.author
    authorButton.tintColor = .secondaryLabel
    authorButton.tapAction = { [comment] in
      guard comment.collapsed.value == false else { return }
      LinkHandler.openRedditUser(userName: comment.author)
    }
  }

  override func didLoad() {
    super.didLoad()
    userContext?.register(view: authorButton.view)
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

    comment.scoreTextObserver
      .bind(to: scoreNode.rx.text)
      .disposed(by: disposeBag)

    let voteColor = comment.voteDirectionRelay
      .map { vote -> UIColor in
        switch vote {
        case .none:
          return .secondaryLabel

        case .up:
          return R.color.orangeRed().unsafelyUnwrapped

        case .down:
          return R.color.periwinkle().unsafelyUnwrapped

        }
      }

    voteColor
      .bind(to: scoreNode.rx.textColor)
      .disposed(by: disposeBag)

    voteColor
      .bind(to: swipeVoteIndicator.rx.imageTintColor)
      .disposed(by: disposeBag)

    Observable.combineLatest(Settings.swipeMode.skip(1), comment.voteDirectionRelay.skip(1))
      .filter { $0.0 }
      .subscribe(onNext: { [weak self] _ in
        self?.setNeedsLayout()
      }).disposed(by: disposeBag)

    comment.voteDirectionRelay
      .distinctUntilChanged()
      .map { vote -> UIImage? in
        switch vote {
        case .none:
          return nil

        case .up:
          return R.image.icon_upvote()

        case .down:
          return R.image.icon_downvote()

        }
      }
      .bind(to: swipeVoteIndicator.rx.image)
      .disposed(by: disposeBag)
    
    comment.ageText
      .bind(to: ageNode.rx.text)
      .disposed(by: disposeBag)

    Settings.showCommentFlair
      .distinctUntilChanged()
      .throttle(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
      .subscribe(onNext: { [weak self] _ in
        self?.setNeedsLayout()
      }).disposed(by: disposeBag)
    
    comment.distinguishedColor
      .filterNil()
      .bind(to: authorButton.rx.tintColor)
      .disposed(by: disposeBag)

  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let scoreHorizontal = ASStackLayoutSpec.horizontal()
    scoreHorizontal.children = [scoreNode]
    if Settings.swipeMode.value && comment.voteDirection != .none {
      scoreHorizontal.children?.append(swipeVoteIndicator)
    }
    scoreHorizontal.verticalAlignment = .center

    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [authorButton, authorAgeSeparator, ageNode, ageScoreSeparator, scoreHorizontal]

    if let flairNode = flairNode, Settings.showCommentFlair.value {
      horizontal.children?.append(contentsOf: [scoreFlairSeparator, flairNode])
    }

    horizontal.style.flexShrink = 1
    horizontal.verticalAlignment = .bottom

    return horizontal
  }

}
