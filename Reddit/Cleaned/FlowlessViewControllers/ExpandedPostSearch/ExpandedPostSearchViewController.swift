//
//  ExpandedPostSearchViewController.swift
//  Reddit
//
//  Created by made2k on 7/16/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit

class ExpandedPostSearchViewController: ASViewController<ASTableNode> {

  let model: LinkSearchModel
  
  init(searchModel: LinkSearchModel) {
    self.model = searchModel
    
    let table = ASTableNode(style: .plain)
    table.hideEmptyCells()
    table.backgroundColor = .systemBackground

    super.init(node: table)

    model.bind(to: table, delegate: SharedListingsCellDelegate.shared)
    table.batchFetchingDelegate = self
    model.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let query = model.query.value {
      title = "Results for: \(query)"
    }
    
  }

}
