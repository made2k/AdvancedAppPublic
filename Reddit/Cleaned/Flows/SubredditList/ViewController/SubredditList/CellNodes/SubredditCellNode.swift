//
//  SubredditCellNode.swift
//  Reddit
//
//  Created by made2k on 5/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Haptica
import RxSwift

class SubredditCellNode: ASCellNode {

  private let subredditName: String

  private let imageNode = ASNetworkImageNode()
  private let textNode = TextNode().then {
    $0.textColor = .label
  }
  private let favoriteIndicator = ASImageNode().then {
    $0.isUserInteractionEnabled = true
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .label
    $0.style.preferredSize = CGSize(width: 28, height: 28)
  }

  var hidesFavorite = false { didSet { setNeedsLayout() } }

  private let disposeBag = DisposeBag()

  convenience init(model: SubredditModel, overrideImage: UIImage?, backgroundColor: UIColor) {
    self.init(
      subredditName: model.title,
      iconUrl: model.subreddit?.iconImage,
      overrideImage: overrideImage,
      backgroundColor: backgroundColor
    )
  }
  
  init(subredditName: String, iconUrl: URL?, overrideImage: UIImage?, backgroundColor: UIColor) {
    self.subredditName = subredditName
    
    super.init()
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    
    self.backgroundColor = backgroundColor
    
    let height: CGFloat = 50
    style.minHeight = ASDimension(unit: .points, value: height)
    
    let imageSize = height - 10
    imageNode.style.preferredSize = CGSize(square: imageSize)
    imageNode.cornerRadius = imageSize / 2
    
    if let image = overrideImage {
      imageNode.image = image
      
    } else if let url = iconUrl {
      imageNode.url = url

    } else {
      imageNode.image = R.image.subreddit_missing_icon()
    }
    
    setupBindings()

  }

  private func setupBindings() {

    Settings.favoriteSubreddits
      .mapMany { [weak self] favorite -> Bool in
        guard let self = self else { return false }
        return favorite ~== self.subredditName
      }
      .map { $0.contains(true) }
      .map { $0 ? R.image.icon_favorite_filled() : R.image.icon_favorite_empty() }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .bind(to: favoriteIndicator.rx.image)
      .disposed(by: disposeBag)

    Observable.just(subredditName)
      .bind(to: textNode.rx.text)
      .disposed(by: disposeBag)

    favoriteIndicator.rx.tap
      .subscribe(onNext: { [unowned self] in
        self.favoriteButtonPressed()
      }).disposed(by: disposeBag)

  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let imageTextHorizontalSpec = ASStackLayoutSpec.horizontal()
    imageTextHorizontalSpec.children = [imageNode, textNode]
    imageTextHorizontalSpec.verticalAlignment = .center
    imageTextHorizontalSpec.spacing = 8

    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [imageTextHorizontalSpec]
    if hidesFavorite == false { horizontal.children?.append(favoriteIndicator) }
    horizontal.spacing = 8
    horizontal.justifyContent = .spaceBetween
    horizontal.verticalAlignment = .center

    let inset = ASInsetLayoutSpec()
    inset.child = horizontal
    inset.insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

    return inset
  }

  private func favoriteButtonPressed() {

    Haptic.impact(.light).generate()

    if let index = Settings.favoriteSubreddits.value.firstIndex(where: { $0 ~== subredditName }) {
      Settings.favoriteSubreddits.remove(at: index)

    } else {
      Settings.favoriteSubreddits.append(subredditName)
    }

  }

}
