//
//  SearchViewController.swift
//  Reddit
//
//  Created by made2k on 7/16/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class SearchViewController: ASViewController<ASTableNode> {
  
  // MARK: - Elements
  
  private let searchController: UISearchController = {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.dimsBackgroundDuringPresentation = false
    return searchController
  }()

  
  // MARK: - Properties
  
  let model: SearchModel
  let delegate: SearchViewControllerDelegate
  let disposeBag = DisposeBag()
  
  // MARK: - Initialization
  
  init(model: SearchModel, delegate: SearchViewControllerDelegate) {
    self.model = model
    self.delegate = delegate
    
    let table = ASTableNode(style: .grouped)
    table.backgroundColor = .systemGroupedBackground
    table.keyboardDismissMode = .onDrag
    
    super.init(node: table)
    definesPresentationContext = true
    title = R.string.search.searchViewControllerTitle()
    
    initializeSearchController()
    setupTableBindings()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initializeSearchController() {
    searchController.searchResultsUpdater = self

    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
      self?.searchController.searchBar.becomeFirstResponder()
    }
  }

}
