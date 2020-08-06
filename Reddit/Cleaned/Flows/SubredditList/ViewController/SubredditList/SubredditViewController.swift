//
//  SubredditViewController.swift
//  Reddit
//
//  Created by made2k on 3/1/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit
import RxSwift

class SubredditViewController: ASViewController<ASTableNode> {

  enum Sections: Int, CaseIterable {
    case favorite
    case `default`
    case feeds
    case subscribed
  }

  let model: SubredditListViewModel
  let delegate: SubredditViewControllerDelegate

  var reorderingDisposeBag = DisposeBag()
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  init(model: SubredditListViewModel, style: UITableView.Style, delegate: SubredditViewControllerDelegate) {
    self.model = model
    self.delegate = delegate

    let node = ASTableNode(style: style)
    node.backgroundColor = .systemGroupedBackground

    super.init(node: node)

    definesPresentationContext = true
    title = R.string.subredditList.viewControllerTitle()
    
    node.dataSource = self
    node.delegate = self
    node.reorderDelegate = self

    node.addPullToRefresh { [unowned self] in self.refresh(control: $0) }

    setupBindings()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    hideBackButtonTitle()
  }

  // MARK: - Bindings

  private func setupBindings() {

    model.customFeeds
      .asVoid()
      .subscribe(onNext: { [unowned self] in
        self.node.reloadSection(Sections.feeds.rawValue, with: .automatic)
      }).disposed(by: disposeBag)

    model.subscribedSubreddits
      .asVoid()
      .subscribe(onNext: { [unowned self] in
        self.node.reloadSection(Sections.subscribed.rawValue, with: .automatic)
      }).disposed(by: disposeBag)

    setupReorderBoundBindings()
  }

  func setupReorderBoundBindings(skipCount: Int = 0) {

    reorderingDisposeBag = DisposeBag()
    
    model.favoriteNames
      .asVoid()
      .skip(skipCount)
      .subscribe(onNext: { [unowned self] in
        self.node.reloadSection(Sections.favorite.rawValue, with: .automatic)
      }).disposed(by: reorderingDisposeBag)

  }

  // MARK: - Actions

  private func refresh(control: UIRefreshControl) {

    firstly {
      model.refreshAll()

    }.ensure {
      control.endRefreshing()

    }.cauterize()

  }

}
