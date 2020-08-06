//
//  ASDisplayNode+Additions.swift
//  Reddit
//
//  Created by made2k on 4/11/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit

extension ASDisplayNode {

  // MARK: - Initializers

  convenience init(automanaged: Bool) {
    self.init()
    automaticallyManagesSubnodes = true
  }

  // MARK: - Helpers

  func isChild(of node: ASDisplayNode) -> Bool {

    var supernode = self.supernode

    while let node = supernode {

      if supernode === node { return true }

      supernode = node.supernode
    }

    return false
  }


  // MARK: - Subnodes

  func allNodes(at point: CGPoint) -> [ASDisplayNode] {

    var stack = [ASDisplayNode]()
    var result = [ASDisplayNode]()

    let startValue: ASDisplayNode
    let startPoint: CGPoint

    if let table = self as? ASTableNode {
      startValue = table.node(at: point)
      startPoint = startValue.view.convert(point, from: table.view)

    } else {
      startValue = self
      startPoint = point
    }

    stack.append(startValue)

    while let node = stack.popLast() {

      let localPoint = node.convert(startPoint, from: startValue)
      
      if node.bounds.contains(localPoint) {
        result.append(node)
      }

      stack.append(contentsOf: node.subnodes ?? [])
    }

    return result
  }

  func subnodes<T: ASDisplayNode>(of type: T.Type) -> [T] {
    return subnodes?.filter { $0.isKind(of: type) } as? [T] ?? []
  }
  
  // MARK: - Animations
  
  func fadeOut(duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
    if isHidden {
      isHidden = false
    }
    
    UIView.animate(withDuration: duration, animations: {
      self.alpha = 0
    }, completion: completion)
  }
  
  func fadeIn(duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
    if isHidden {
      isHidden = false
    }
    UIView.animate(withDuration: duration, animations: {
      self.alpha = 1
    }, completion: completion)
  }

}
