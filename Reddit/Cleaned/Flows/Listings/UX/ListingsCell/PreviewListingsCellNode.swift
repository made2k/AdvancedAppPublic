//
//  PreviewListingsCellNode.swift
//  Reddit
//
//  Created by made2k on 1/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxCocoa
import RxSwift
import Then

class PreviewListingsCellNode: ListingsCellNode {

  private struct AssociatedKeys {
    static var visibleDisposeBag: UInt8 = 0
  }

  lazy var previewNode: RedditMediaNode = {
    let node = RedditMediaNode(linkModel: model, showSeparator: true)
    node.shouldAutoPlay = false
    return node
  }()
  let paddingNode = ColorNode(backgroundColor: .secondarySystemBackground).then {
    $0.style.height = ASDimension(unit: .points, value: 10)
  }

  private lazy var topSeparatorNode: ASDisplayNode = createSeparator()
  private lazy var bottomSeparatorNode: ASDisplayNode = createSeparator()

  private lazy var scrollViewFrameRelay = BehaviorRelay<CGRect?>(value: nil)
  private lazy var previewRectRelay = BehaviorRelay<CGRect>(value: .zero)

  private var visualDisposeBag: DisposeBag {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.visibleDisposeBag) as? DisposeBag ?? DisposeBag()
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.visibleDisposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private func previewDidEnterVisibleState() {
    visualDisposeBag = DisposeBag()

    let allowedOffset: CGFloat = 0.15

    // Scroll view frame extended by 20% to help decide playing a node
    let scrollFrameObservable = scrollViewFrameRelay
      .filterNil()
      .map { frame -> (CGRect, CGFloat) in
        return (frame, frame.height * allowedOffset) }
      .map { frame, offset -> CGRect in
        return CGRect(x: 0, y: frame.origin.y - offset, width: frame.width, height: frame.height + offset/* * 2*/)
      }
      .distinctUntilChanged()

    Observable.combineLatest(scrollFrameObservable, previewRectRelay)
      .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
      .map { $0.contains($1) }
      .distinctUntilChanged()
      .subscribe(onNext: { [unowned self] in
        $0 ? self.previewNode.play() : self.previewNode.pause()
      }).disposed(by: visualDisposeBag)

  }

  private func previewDidExitVisibleState() {
    visualDisposeBag = DisposeBag()
    previewNode.pause()
  }

  // MARK: - Visibility

  override func cellNodeVisibilityEvent(_ event: ASCellNodeVisibilityEvent,
                                        in scrollView: UIScrollView?,
                                        withCellFrame cellFrame: CGRect) {

    super.cellNodeVisibilityEvent(event, in: scrollView, withCellFrame: cellFrame)

    guard let scrollView = scrollView, cellFrame != .zero else { return }

    scrollViewFrameRelay.accept(scrollView.frame)

    if event == .visible {
      previewDidEnterVisibleState()
    }

    if event == .invisible {
      previewDidExitVisibleState()
    }

    var previewFrame = previewNode.view.convert(previewNode.frame, to: scrollView)
    previewFrame.origin.y -= scrollView.contentOffset.y
    previewFrame.origin.y -= scrollView.safeAreaInsets.top

    previewRectRelay.accept(previewFrame)
  }

  // MARK: - Layout

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let titleDomainSpec = ASStackLayoutSpec.vertical()
    titleDomainSpec.children = [titleTextNode, domainTextNode]
    titleDomainSpec.style.flexShrink = 1
    titleDomainSpec.style.flexGrow = 1
    titleDomainSpec.spacing = 4

    let contentHorizontal = ASStackLayoutSpec.horizontal()
    contentHorizontal.spacing = 16
    contentHorizontal.verticalAlignment = .top

    if Settings.thumbnailSide.value == .left {
      contentHorizontal.children = [titleDomainSpec, voteButtonSpec]

    } else {
      contentHorizontal.children = [voteButtonSpec, titleDomainSpec]
    }

    let contentBottomDetailSpec = ASStackLayoutSpec.vertical()
    contentBottomDetailSpec.children = [contentHorizontal, bottomDetailSpec]
    contentBottomDetailSpec.spacing = 12
    if let flairSpec = nsfwFlairSpec {
      contentBottomDetailSpec.children?.insert(flairSpec, at: 1)
    }

    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = contentBottomDetailSpec
    insetSpec.insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    let previewVertical = ASStackLayoutSpec.vertical()
    previewVertical.children = [topSeparatorNode, previewNode, insetSpec, bottomSeparatorNode, paddingNode]

    return previewVertical
  }

}
