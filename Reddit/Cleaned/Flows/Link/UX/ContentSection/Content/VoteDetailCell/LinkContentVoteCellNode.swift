//
//  VoteCellNode.swift
//  Reddit
//
//  Created by made2k on 10/28/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxCocoa
import RxSwift
import Then
import UIKit

class LinkContentVoteCellNode: ASCellNode {

  // MARK: - Nodes
  
  private let authorSubredditNode: VoteCellAuthorSubredditNode
  private let linkInfoNode: VoteCellLinkInfoNode
  private let voteScoreNode: VoteCellScoreNode
  
  private let moreButtonNode = ButtonNode().then {
    $0.tintColor = .secondaryLabel
    $0.image = R.image.iconEllipsisCircleSmall()
    $0.hitTestSlop = UIEdgeInsets(inset: -2)
    $0.style.preferredSize = CGSize(width: 20, height: 20)
  }
  
  private lazy var topSeparator = createSeperator()
  private lazy var bottomSeparator = createSeperator()

  private func createSeperator() -> ASDisplayNode {
    let node = ASDisplayNode()
    node.style.height = ASDimension(unit: .points, value: 1)
    node.backgroundColor = .separator
    node.alpha = 0.7
    return node
  }

  private lazy var loadAllIndicator: VoteLinkCellLoadAllNode = {
    return VoteLinkCellLoadAllNode().then {
      $0.tapAction = { [unowned self] in
        self.loadAllComments?()
      }
    }
  }()
  
  // MARK: - Public properties
  
  var moreActions: ((ASDisplayNode) -> Void)? = nil
  var loadAllComments: (() -> Void)?
  
  // MARK: - Private properties
  
  private let model: LinkModel
  
  private let showsLoadAll = BehaviorRelay<Bool>(value: false)
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Init
  
  init(link: LinkModel, focusingObserver: Observable<String?>) {
    self.model = link

    authorSubredditNode = VoteCellAuthorSubredditNode(linkModel: link)
    linkInfoNode = VoteCellLinkInfoNode(linkModel: link)
    voteScoreNode = VoteCellScoreNode(linkModel: link)

    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    backgroundColor = .systemBackground

    moreButtonNode.tapAction = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.moreActions?(strongSelf.moreButtonNode)
    }

    setupBindings(focusingObserver)
  }

  private func setupBindings(_ observer: Observable<String?>) {

    observer
      .distinctUntilChanged()
      .map { $0 != nil }
      .subscribe(onNext: { [unowned self] value in
        self.showsLoadAll.accept(value)
      }).disposed(by: disposeBag)

    showsLoadAll.asObservable()
      .distinctUntilChanged()
      .subscribe(onNext: { [unowned self] _ in
        self.setNeedsLayout()
      }).disposed(by: disposeBag)

  }
  
  // MARK: - Layout
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let bottomHorizontalSpec = ASStackLayoutSpec.horizontal()
    bottomHorizontalSpec.children = [linkInfoNode, ASLayoutSpec.spacer(), voteScoreNode, moreButtonNode]
    bottomHorizontalSpec.spacing = 8
    bottomHorizontalSpec.verticalAlignment = .center
    
    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.children = [authorSubredditNode, bottomHorizontalSpec]
    verticalSpec.spacing = 8
    
    let insetSpec = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16),
      child: verticalSpec)
    
    let separatorVerticalSpec = ASStackLayoutSpec.vertical()
    separatorVerticalSpec.children = [topSeparator, insetSpec, bottomSeparator]

    if showsLoadAll.value {
      separatorVerticalSpec.children?.append(loadAllIndicator)
    }
    
    return separatorVerticalSpec
  }
  
}
