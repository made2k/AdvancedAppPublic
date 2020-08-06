//
//  VoteCellLinkInfoNode.swift
//  Reddit
//
//  Created by made2k on 1/30/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxCocoa
import RxSwift

class VoteCellLinkInfoNode: ASDisplayNode {

  private let gildingNode: GildingNode
  private let likePercentNode = ImageTextNode(
    image: R.image.icon_controversal().unsafelyUnwrapped,
    weight: .semibold,
    textColor: .secondaryLabel)
  private let commentNode = ImageTextNode(
    image: R.image.icon_comment().unsafelyUnwrapped,
    weight: .semibold,
    textColor: .secondaryLabel)
  private let ageNode = ImageTextNode(
    image: R.image.icon_time().unsafelyUnwrapped,
    weight: .semibold,
    textColor: .secondaryLabel)

  private let model: LinkModel
  private let disposeBag = DisposeBag()

  init(linkModel: LinkModel) {

    self.model = linkModel
    gildingNode = GildingNode(gildings: linkModel.link.gildings)

    super.init()
    automaticallyManagesSubnodes = true
    style.flexShrink = 1

    setupBindings()
  }

  private func setupBindings() {
    
    Observable<Int>.just(model.link.commentCount)
      .map { StringUtils.numberSuffix($0, min: 1000) }
      .bind(to: commentNode.rx.text)
      .disposed(by: disposeBag)
    
    Observable.just(model.link.created)
      .map { $0.timeAgo }
      .bind(to: ageNode.rx.text)
      .disposed(by: disposeBag)
    
    model.likePercent
      .filter { $0 == nil }
      .map { _ in "-- %" }
      .bind(to: likePercentNode.rx.text)
      .disposed(by: disposeBag)
    
    model.likePercent
      .filterNil()
      .map { Int($0 * 100) }
      .map { "\($0)%" }
      .bind(to: likePercentNode.rx.text)
      .disposed(by: disposeBag)
    
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let children: [ASLayoutElement] = [likePercentNode, commentNode, ageNode]
    
    return constrainedSize.max.width != .infinity ?
      verticalSpec(children: children) :
      horizontalSpec(children: children)
  }
  
  private func horizontalSpec(children: [ASLayoutElement]) -> ASLayoutSpec {
    
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [likePercentNode, commentNode, ageNode]
    horizontal.flexWrap = .wrap
    horizontal.verticalAlignment = .center
    
    if gildingNode.hasBeenGilded {
      horizontal.children?.prepend(gildingNode)
    }
    
    horizontal.spacing = 6
    
    return horizontal
  }
  
  private func verticalSpec(children: [ASLayoutElement]) -> ASLayoutSpec {
    
    let initialHorizontal = ASStackLayoutSpec.horizontal()
    initialHorizontal.children = [children.first].compactMap { $0 }
    initialHorizontal.spacing = 2
    
    if gildingNode.hasBeenGilded {
      initialHorizontal.children?.prepend(gildingNode)
    }
    
    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.children = [initialHorizontal] + children.suffix(from: 1)
    verticalSpec.horizontalAlignment = .left
    verticalSpec.spacing = 2
    
    return verticalSpec
  }

}
