//
//  FilterTypeViewController.swift
//  Reddit
//
//  Created by made2k on 4/26/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class FilterTypeViewController: ASViewController<ASTableNode> {

  override init() {
    super.init(node: ASTableNode(style: .grouped))
    node.delegate = self
    node.dataSource = self
    
    title = "Filters"

    node.backgroundColor = .systemGroupedBackground
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    node.reloadData()
  }
  
}

extension FilterTypeViewController: ASTableDataSource {
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return 2
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    if indexPath.section == 0 {
      return FilterTypeCellNode(type: .post)
    }
    
    return FilterTypeCellNode(type: .comment)
  }
  
}

extension FilterTypeViewController: ASTableDelegate {
  
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let vc = FiltersViewController(type: indexPath.section == 0 ? .post : .comment)
    navigationController?.pushViewController(vc, animated: true)
  }
  
}
