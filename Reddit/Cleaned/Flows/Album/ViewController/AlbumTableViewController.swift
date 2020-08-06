//
//  AlbumTableViewController.swift
//  Reddit
//
//  Created by made2k on 3/5/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit

class AlbumTableViewController: ASViewController<ASTableNode> {
  
  var delegate: (ASTableDataSource & ASTableDelegate)? {
    didSet {
      node.dataSource = delegate
      node.delegate = delegate
    }
  }
  
  override init() {
    let table = ASTableNode(style: .grouped)
    table.backgroundColor = .systemGroupedBackground
    
    super.init(node: table)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func reloadData() {
    node.reloadData()
  }
  
}

