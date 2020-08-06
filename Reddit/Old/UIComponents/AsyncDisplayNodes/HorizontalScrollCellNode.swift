//
//  HorizontalScrollCellNode.swift
//  Reddit
//
//  Created by made2k on 1/27/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import Then
import UIKit

class HorizontalScrollCellNode: ASCellNode, ASCollectionDelegate, ASCollectionDataSource {

  let titleText = TextNode(weight: .bold, color: .secondaryLabel)
  let collectionNode: ASCollectionNode
  
  let collectionSize: CGFloat
  
  init(size: CGFloat, title: String) {
    collectionSize = size
    
    titleText.text = title
    
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    flowLayout.estimatedItemSize = CGSize(width: collectionSize, height: collectionSize)
    flowLayout.minimumLineSpacing = 8
    
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    collectionNode.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    collectionNode.backgroundColor = .clear
    
    super.init()
    
    selectionStyle = .none
    
    onDidLoad { (node) in
      node.view.backgroundColor = .systemBackground
    }
    
    collectionNode.delegate = self
    collectionNode.dataSource = self
    
    addSubnode(titleText)
    addSubnode(collectionNode)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let collectionNodeSize = CGSize(width: constrainedSize.max.width, height: collectionSize)
    collectionNode.style.preferredSize = collectionNodeSize
    
    let titleInset = ASInsetLayoutSpec()
    titleInset.insets = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
    titleInset.child = titleText
    
    let vertical = ASStackLayoutSpec.vertical()
    vertical.children = [titleInset, collectionNode]
    
    return vertical
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return 0
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      ASCellNode()
    }
  }
}
