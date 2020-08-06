//
//  SidebarHeaderNode.swift
//  Reddit
//
//  Created by made2k on 4/22/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import Haptica
import PromiseKit
import RxSwift

class SidebarHeaderNode: ASCellNode {
  
  private let model: SubredditModel
  
  private let iconNode = ASNetworkImageNode().then {
    $0.style.preferredSize = CGSize(width: 40, height: 40)
    $0.cornerRadius = 20
    $0.borderColor = UIColor.gray.cgColor
    $0.borderWidth = 1
  }
  
  private let titleNode = TextNode()
  private let createdNode = TextNode(color: .secondaryLabel)
  private let subscriberNode = TextNode()
  private let activeNode = TextNode()
  
  private let subscribeButton = ButtonNode(weight: .semibold, size: .large)
  
  private let disposeBag = DisposeBag()
  
  init(subredditModel: SubredditModel) {
    
    self.model = subredditModel
    
    super.init()
    automaticallyManagesSubnodes = true
    
    subscribeButton.tapAction = { [unowned self] in
      self.subscribeButtonPressed()
    }
    
    setupBindings()
  }
  
  private func setupBindings() {
    
    model.subscribedObserver
      .map { $0 ?
        R.string.sideBar.unsubscribeButton() :
        R.string.sideBar.subscribeButton()
      }.bind(to: subscribeButton.rx.title)
      .disposed(by: disposeBag)
    
    let subreddit = Observable.just(model.subreddit).filterNil()
    
    subreddit
      .map { $0.displayNamePrefix }
      .bind(to: titleNode.rx.text)
      .disposed(by: disposeBag)
    
    subreddit
      .map { $0.iconImage }
      .bind(to: iconNode.rx.url)
      .disposed(by: disposeBag)
    
    subreddit
      .map { $0.created }
      .map { date -> String in
        let formatter = DateFormatter(dateStyle: .short)
        return formatter.string(from: date)
      }.map { R.string.sideBar.createdAt($0) }
      .bind(to: createdNode.rx.text)
      .disposed(by: disposeBag)
    
    subreddit
      .map { $0.subscriberCount }
      .map { StringUtils.numberSuffix($0) }
      .map { R.string.sideBar.subCount($0) }
      .bind(to: subscriberNode.rx.text)
      .disposed(by: disposeBag)
    
    model.activeUserCount
      .filterNil()
      .map { R.string.sideBar.activeCount($0.description) }
      .bind(to: activeNode.rx.text)
      .disposed(by: disposeBag)
    
    model.activeUserCount
      .filter { $0 == nil }
      .map { _ -> String in R.string.sideBar.activeCount("--") }
      .bind(to: activeNode.rx.text)
      .disposed(by: disposeBag)
    
  }
  
  private func subscribeButtonPressed() {
    
    let promise: Promise<Void> = model.subscribed ? model.unsubscribe() : model.subscribe()
    
    firstly {
      promise
      
    }.done {
      Haptic.notification(.success).generate()
      
    }.catch { _ in
      Haptic.notification(.error).generate()
    }
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let titleDateSpec = ASStackLayoutSpec.vertical()
    titleDateSpec.children = [titleNode, createdNode]
    
    let iconInfoSpec = ASStackLayoutSpec.horizontal()
    iconInfoSpec.children = []
    if iconNode.url != nil {
      iconInfoSpec.children?.append(iconNode)
    }
    iconInfoSpec.children?.append(titleDateSpec)
    iconInfoSpec.spacing = 8
    
    let topSpec: ASLayoutSpec
    
    if constrainedSize.max.width < 375 {
      let underHorizontal = ASStackLayoutSpec.horizontal()
      underHorizontal.children = [subscriberNode, activeNode]
      underHorizontal.justifyContent = .spaceAround
      underHorizontal.spacing = 12
      
      let vertical = ASStackLayoutSpec.vertical()
      vertical.children = [iconInfoSpec, underHorizontal]
      vertical.spacing = 8
      topSpec = vertical
      
    } else {
      
      let rightVertical = ASStackLayoutSpec.vertical()
      rightVertical.horizontalAlignment = .right
      rightVertical.children = [subscriberNode, activeNode]
      rightVertical.style.flexShrink = 1
      
      let topHorizontal = ASStackLayoutSpec.horizontal()
      topHorizontal.children = [iconInfoSpec, rightVertical]
      topHorizontal.spacing = 4
      topHorizontal.justifyContent = .spaceBetween
      topHorizontal.style.flexShrink = 1
      topSpec = topHorizontal
    }
    
    let contentSubscribeVerticalSpec = ASStackLayoutSpec.vertical()
    contentSubscribeVerticalSpec.children = [topSpec]
    contentSubscribeVerticalSpec.spacing = 8
    
    if AccountModel.currentAccount.value.isSignedIn {
      let subscribeSpec = ASStackLayoutSpec.horizontal()
      subscribeSpec.children = [ASLayoutSpec.spacer(), subscribeButton]
      subscribeSpec.horizontalAlignment = .right
      contentSubscribeVerticalSpec.children?.append(subscribeSpec)
    }
    
    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    inset.child = contentSubscribeVerticalSpec
    inset.style.flexShrink = 1
    
    return inset
  }

}
