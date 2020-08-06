//
//  UserPreviewViewController.swift
//  Reddit
//
//  Created by made2k on 8/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit
import RxCocoa
import RxSwift

final class UserPreviewViewController: ASViewController<ASDisplayNode> {
  
  private static var estimatedPreviewSize: CGSize = CGSize(width: 300, height: 100)
  
  private let sizingScrollNode: SizingScrollNode
  private let disposeBag = DisposeBag()

  init(username: String) {
    
    let previewNode = UserPreviewNode(username: username)
    let sizingScrollNode = SizingScrollNode(node: previewNode)
    self.sizingScrollNode = sizingScrollNode
    
    super.init(node: sizingScrollNode)
    
    preferredContentSize = UserPreviewViewController.estimatedPreviewSize
    setupBindings()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  private func setupBindings() {
    
    sizingScrollNode.sizeSubject
      .subscribeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [unowned self] calculatedSize in
        self.preferredContentSize = calculatedSize
        UserPreviewViewController.estimatedPreviewSize = calculatedSize
      }).disposed(by: disposeBag)
    
  }
  
}

private final class SizingScrollNode: ASScrollNode {
  
  private let previewNode: UserPreviewNode
  
  let sizeSubject = ReplaySubject<CGSize>.create(bufferSize: 1)
  
  private let disposeBag = DisposeBag()
  
  init(node: UserPreviewNode) {
    self.previewNode = node
    super.init()
        
    automaticallyManagesSubnodes = true
    automaticallyManagesContentSize = true
  }
  
  override func didLoad() {
    super.didLoad()
    setupBindings()
  }
  
  private func setupBindings() {
    
    view.rx.observe(CGSize.self, "contentSize")
      .filterNil()
      .filter{ $0 != .zero }
      .distinctUntilChanged()
      .bind(to: sizeSubject)
      .disposed(by: disposeBag)
    
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASWrapperLayoutSpec(layoutElement: previewNode)
  }
  
}

private final class UserPreviewNode: ASDisplayNode {
  
  private let loadingBackground = ColorNode(backgroundColor: .systemBackground)
  private let loadingNode = NVActivityIndicatorNode(type: .ballTrianglePath).then {
    $0.color = .label
  }
  
  private let avatarNode = ASNetworkImageNode().then {
    $0.style.preferredSize = CGSize(square: 50)
    $0.cornerRadius = 10
  }
  private let nameNode = TextNode(weight: .bold, size: .large).then {
    $0.maximumNumberOfLines = 1
    $0.truncationMode = .byTruncatingTail
    $0.pointSizeScaleFactors = [0.95, 0.9, 0.85, 0.8, 0.75]
  }
  private let ageNode = TextNode(color: .secondaryLabel)
  private let postKarmaNode = TextNode(color: .secondaryLabel)
  private let commentKarmaNode = TextNode(color: .secondaryLabel)
  
  private var userModel: UserModel? {
    didSet { copyValues(from: userModel) }
  }
  private let username: String
  
  var onSizeUpdate: ((CGSize) -> Void)?
  
  init(username: String) {
    self.username = username
    defer {
      self.userModel = UserCache.shared.lookup(username)
    }

    super.init()
    
    automaticallyManagesSubnodes = true
  }
  
  override func didEnterPreloadState() {
    super.didEnterPreloadState()
    guard userModel == nil else { return }
    
    firstly {
      after(seconds: 0.5)
      
    }.then {
      UserCache.shared.loadIfNeeded(self.username)
      
    }.done {
      self.userModel = $0
      
    }.done {
      self.setNeedsLayout()
      
    }.cauterize()
  }
  
  private func copyValues(from model: UserModel?) {
    guard let model = model else { return }
    avatarNode.url = model.user.icon
    nameNode.text = model.username
    
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    let dateString = formatter.string(from: model.user.created)
    ageNode.text = R.string.userPreview.age(dateString)
    
    let postKarmaString = StringUtils.numberSuffix(model.user.linkKarma, min: 10000)
    postKarmaNode.text = R.string.userPreview.postKarma(postKarmaString)
    
    let commentKarmaString = StringUtils.numberSuffix(model.user.commentKarma, min: 10000)
    commentKarmaNode.text = R.string.userPreview.postKarma(commentKarmaString)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    if userModel == nil {
      return loadingSpec()
    } else {
      return userSpec()
    }
  }
  
  private func loadingSpec() -> ASLayoutSpec {
    
    let centerSpec = ASCenterLayoutSpec(horizontalPosition: .center,
                                        verticalPosition: .center,
                                        sizingOption: .minimumSize,
                                        child: loadingNode)
    let overlaySpec = ASOverlayLayoutSpec(child: loadingBackground, overlay: centerSpec)
    
    return overlaySpec
  }
  
  private func userSpec() -> ASLayoutSpec {
    
    let karmaVerticalStack = ASStackLayoutSpec.vertical()
    karmaVerticalStack.children = [postKarmaNode, commentKarmaNode]
    
    let textVerticalStack = ASStackLayoutSpec.vertical()
    textVerticalStack.children = [nameNode, ageNode, karmaVerticalStack]
    textVerticalStack.spacing = 8
    textVerticalStack.style.flexShrink = 1
    
    let imageTextHorizontalStack = ASStackLayoutSpec.horizontal()
    imageTextHorizontalStack.children = [avatarNode, textVerticalStack]
    imageTextHorizontalStack.spacing = 16
    
    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = imageTextHorizontalStack
    insetSpec.insets = UIEdgeInsets(inset: 16)
    
    return insetSpec
  }
  
}
