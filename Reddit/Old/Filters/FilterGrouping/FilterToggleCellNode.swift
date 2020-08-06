//
//  FilterToggleCellNode.swift
//  Reddit
//
//  Created by made2k on 7/19/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit

class FilterToggleCellNode: ASCellNode {
  
  private let titleNode = TextNode().then {
    $0.textColor = .label
  }
  private let switchNode = ASDisplayNode { () -> UIView in
    return UISwitch()
  }
  private var enabledSwitch: UISwitch {
    return switchNode.view as! UISwitch
  }
  
  private let onSwitch: (Bool) -> Void
  
  init(title: String, enabled: Bool, onSwitch: @escaping (Bool) -> Void) {
    self.onSwitch = onSwitch
    
    super.init()
    automaticallyManagesSubnodes = true
    
    
    titleNode.text = title
    enabledSwitch.isOn = enabled
    switchNode.backgroundColor = .clear
    switchNode.style.minSize = UISwitch().frame.size
    
    enabledSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
  }
  
  @objc private func switchDidChange() {
    onSwitch(enabledSwitch.isOn)
  }
  
  override func didLoad() {
    super.didLoad()
    view.backgroundColor = .secondarySystemGroupedBackground
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [titleNode, switchNode]
    horizontal.spacing = 8
    horizontal.justifyContent = .spaceBetween
    horizontal.verticalAlignment = .center
    
    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    inset.child = horizontal
    
    return inset
  }

}
