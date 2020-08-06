//
//  GifVideoContainerNode.swift
//  Reddit
//
//  Created by made2k on 2/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import Then
import UIKit

final class GifVideoContainerNode: ASDisplayNode {
  
  private lazy var progressNode: VisualEffectNode =  {
    let effect: UIBlurEffect
    
    if #available(iOS 13.0, *) {
      effect = UIBlurEffect(style: .systemThinMaterial)
    } else {
      effect = UIBlurEffect(style: .prominent)
    }
    
    let node = VisualEffectNode(effect: effect)
    node.style.height = ASDimension(unit: .points, value: 6)
    node.style.width = ASDimension(unit: .fraction, value: 0)
    node.alpha = 0.85
    return node
  }()
  private let videoNode: GifVideoNode
  private let volumeNode: VolumeImageNode?
  
  private let disposeBag = DisposeBag()
  
  init(videoNode: GifVideoNode) {
    self.videoNode = videoNode
    
    if let asset = videoNode.asset {
      volumeNode = VolumeImageNode(asset: asset)
    } else {
      volumeNode = nil
    }
    
    super.init()
    
    automaticallyManagesSubnodes = true
    
    volumeNode?.tapAction = { [unowned self] in
      self.volumeButtonTapped()
    }
    
    setupBindings()
  }

  private func setupBindings() {
    
    videoNode.videoProgressObserver
      .distinctUntilChanged()
      .throttle(.milliseconds(80), scheduler: MainScheduler.instance)
      .map { CGFloat($0) }
      .map { ASDimension(unit: .fraction, value: $0) }
      .subscribe(onNext: { [unowned self] in
        self.progressNode.style.width = $0
        self.setNeedsLayout()
      }).disposed(by: disposeBag)
    
  }
  
  private func volumeButtonTapped() {
    let newValue = !videoNode.muted
    
    videoNode.muted = newValue
    volumeNode?.muted.accept(newValue)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let horizontal = ASStackLayoutSpec.horizontal()
    if Settings.hideGifProgress == false {
      horizontal.children = [progressNode, ASLayoutSpec.spacer()]
    } else {
      horizontal.children = []
    }
    
    let vertical = ASStackLayoutSpec.vertical()
    vertical.children = [ASLayoutSpec.spacer(), horizontal]
    
    let progressOverlay = ASOverlayLayoutSpec(child: videoNode, overlay: vertical)
    
    if let volumeNode = volumeNode {
      
      let insetSpec = ASInsetLayoutSpec(
        insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
        child: volumeNode)
      
      let horizontalPosition: ASRelativeLayoutSpecPosition
      let verticalPosition: ASRelativeLayoutSpecPosition
      
      switch Settings.volumePosition.value {
      case .topLeft:
        horizontalPosition = .start
        verticalPosition = .start
        
      case .topRight:
        horizontalPosition = .end
        verticalPosition = .start
        
      case .bottomLeft:
        horizontalPosition = .start
        verticalPosition = .end
        
      case .bottomRight:
        horizontalPosition = .end
        verticalPosition = .end
      }
      
      let relativeSpec = ASRelativeLayoutSpec(horizontalPosition: horizontalPosition,
                                              verticalPosition: verticalPosition,
                                              sizingOption: .minimumSize,
                                              child: insetSpec)
      
      return ASOverlayLayoutSpec(child: progressOverlay, overlay: relativeSpec)
      
    }
    
    return progressOverlay
  }
  
}
