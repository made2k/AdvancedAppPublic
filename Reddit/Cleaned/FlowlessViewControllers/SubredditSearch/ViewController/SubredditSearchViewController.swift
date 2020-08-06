//
//  SubredditSearchViewController.swift
//  Reddit
//
//  Created by made2k on 5/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxKeyboard
import RxSwift

class SubredditSearchViewController: ASViewController<ASTableNode> {

  let model: SubredditSearchViewModel
  private(set) weak var delegate: SubredditSearchViewControllerDelegate?
  private let disposeBag = DisposeBag()

  init(model: SubredditSearchViewModel, delegate: SubredditSearchViewControllerDelegate) {
    self.model = model
    self.delegate = delegate

    let node = ASTableNode(style: .plain)
    node.backgroundColor = .systemBackground
    node.hideEmptyCells()

    super.init(node: node)

     node.dataSource = self
     node.delegate = self

    setupBindings()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupBindings() {

    model.searchResults
      .asVoid()
      .subscribe(onNext: { [unowned self] in
        self.node.reloadData()
      }).disposed(by: disposeBag)

    RxKeyboard.instance.visibleHeight
      .drive(onNext: { [unowned self] in
        self.node.contentInset.bottom = $0
      }).disposed(by: disposeBag)

  }

}
