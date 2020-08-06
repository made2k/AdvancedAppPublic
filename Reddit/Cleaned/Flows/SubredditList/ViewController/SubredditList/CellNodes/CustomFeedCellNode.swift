//
//  CustomFeedCellNode.swift
//  Reddit
//
//  Created by made2k on 5/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class CustomFeedCellNode: ASCellNode {

  private let model: FeedModel
  private weak var delegate: SubredditViewControllerDelegate?

  private let imageNode = ASNetworkImageNode()
  private let textNode = TextNode().then {
    $0.textColor = .label
  }
  private let infoButton = ASImageNode().then {
    $0.isUserInteractionEnabled = true
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .label
    $0.style.preferredSize = CGSize(width: 28, height: 28)
  }

  private let disposeBag = DisposeBag()

  init(model: FeedModel, delegate: SubredditViewControllerDelegate) {
    self.model = model
    self.delegate = delegate

    super.init()
    automaticallyManagesSubnodes = true
    selectionStyle = .none

    backgroundColor = .secondarySystemGroupedBackground

    let height: CGFloat = 50
    style.minHeight = ASDimension(unit: .points, value: height)

    let imageSize = height - 10
    imageNode.style.preferredSize = CGSize(square: imageSize)
    imageNode.cornerRadius = imageSize / 2

    if let iconUrl = model.feed.iconUrl {
      imageNode.url = iconUrl
    } else {
      imageNode.image = R.image.subreddit_missing_icon()
    }

    infoButton.image = R.image.icon_info()

    setupBindings()
  }

  private func setupBindings() {

    model.feedTitleObserver
      .bind(to: textNode.rx.text)
      .disposed(by: disposeBag)

    infoButton.rx.tap
      .subscribe(onNext: { [unowned self] in
        self.infoButtonPressed()
      }).disposed(by: disposeBag)

  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let imageTextHorizontalSpec = ASStackLayoutSpec.horizontal()
    imageTextHorizontalSpec.children = [imageNode, textNode]
    imageTextHorizontalSpec.verticalAlignment = .center
    imageTextHorizontalSpec.spacing = 8

    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [imageTextHorizontalSpec, infoButton]
    horizontal.justifyContent = .spaceBetween
    horizontal.verticalAlignment = .center
    horizontal.spacing = 8

    let inset = ASInsetLayoutSpec()
    inset.child = horizontal
    inset.insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

    return inset
  }

  private func infoButtonPressed() {
    delegate?.didTapToEditFeed(model)
  }
  
}
