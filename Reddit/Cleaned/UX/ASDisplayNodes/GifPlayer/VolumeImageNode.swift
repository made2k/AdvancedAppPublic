//
//  VolumeImageNode.swift
//  Reddit
//
//  Created by made2k on 2/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import AVKit
import RxCocoa
import RxSwift

final class VolumeImageNode: ASControlNode {
  
  private let imageNode = ASImageNode().then {
    $0.contentMode = .scaleAspectFit
  }
  private let disposeBag = DisposeBag()
  
  let muted = BehaviorRelay<Bool>(value: true)
  
  init?(asset: AVAsset) {
    guard asset.tracks(withMediaType: .audio).isNotEmpty == true else { return nil }
    
    super.init()
    
    automaticallyManagesSubnodes = true
    style.preferredSize = CGSize(width: 30, height: 30)
    backgroundColor = UIColor.black.withAlphaComponent(0.35)
    cornerRadius = 10
    imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(.white)

    setupBindings(asset: asset)
  }
  
  private func setupBindings(asset: AVAsset) {
    
    muted
      .map { $0 ? R.image.icon_volume_off() : R.image.icon_volume_on() }
      .bind(to: imageNode.rx.image)
      .disposed(by: disposeBag)
    
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let insetSpec = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4),
      child: imageNode)
    
    return insetSpec
  }
  
}
