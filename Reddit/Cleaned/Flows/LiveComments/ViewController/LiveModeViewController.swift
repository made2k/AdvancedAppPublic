//
//  LiveModeViewController.swift
//  Reddit
//
//  Created by made2k on 9/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import Differentiator
import RxCocoa_Texture
import RxSwift

class LiveModeViewController: ASViewController<LiveCommentsDisplayNode> {

  var tableNode: ASTableNode { return node.tableNode }

  private let closeButton = UIBarButtonItem(barButtonSystemItem: .done)
  private let idleButton = UIBarButtonItem(title: nil, style: .plain)

  private let delegate: LiveCommentViewControllerDelegate
  private let disposeBag = DisposeBag()
  private var tableBag = DisposeBag()

  init(delegate: LiveCommentViewControllerDelegate) {
    self.delegate = delegate

    let node = LiveCommentsDisplayNode(delegate: delegate)
    node.backgroundColor = .systemBackground

    super.init(node: node)

    self.setupBindings()
    self.title = "Live"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupBarButtonItems()
  }

  // MARK: - View Setup

  private func setupBarButtonItems() {
    navigationItem.leftBarButtonItem = closeButton
    navigationItem.rightBarButtonItem = idleButton
  }

  private func setupBindings() {

    closeButton.rx.tap
      .take(1)
      .subscribe(onNext: { [unowned self] in
        self.delegate.didDismiss()
      }).disposed(by: disposeBag)

    idleButton.rx.tap
      .map { [unowned self] _ in return !self.delegate.idleTimerRelay.value }
      .bind(to: delegate.idleTimerRelay)
      .disposed(by: disposeBag)

    delegate.idleButtonTitle
      .bind(to: idleButton.rx.title)
      .disposed(by: disposeBag)

  }

}
