//
//  InboxViewController.swift
//  Reddit
//
//  Created by made2k on 1/28/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit
import RedditAPI
import RxSwift

final class InboxViewController: ASViewController<ASTableNode> {

  private lazy var sortButton: UIBarButtonItem = UIBarButtonItem(image: model.inboxType.icon.barButtonSafe, style: .plain)
  private lazy var addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add)

  private(set) var shouldAutoLoad: Bool = false

  let model: InboxModel
  let delegate: InboxViewControllerDelegate
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  init(model: InboxModel, strongDelegate: InboxViewControllerDelegate) {
    self.model = model
    self.delegate = strongDelegate

    let tableNode: ASTableNode = ASTableNode(style: .plain)
    tableNode.backgroundColor = .systemBackground

    super.init(node: tableNode)

    tableNode.dataSource = self
    tableNode.delegate = self
    tableNode.batchFetchingDelegate = self

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationItems()
    setupBindings()

    node.addPullToRefresh { [weak self] _ in
      self?.model.reset()
      self?.loadMessages()
    }

  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    InboxWatcher.shared.clearUnread()
  }

  // MARK: - Bindings

  private func setupBindings() {

    let inboxType: Observable<InboxType> = model.inboxTypeObserver
      .distinctUntilChanged()

    inboxType
      .map { (type: InboxType) -> String in
        return type.title
      }
      .bind(to: rx.title)
      .disposed(by: disposeBag)

    inboxType
      .subscribe(onNext: { [weak self] _ in
        self?.node.reloadData()
        self?.loadMessages()
      })
      .disposed(by: disposeBag)

    inboxType
      .map { (type: InboxType) -> UIImage in
        return type.icon.barButtonSafe
      }
      .bind(to: sortButton.rx.image)
      .disposed(by: disposeBag)

    addButton.rx.tap
      .subscribe(onNext: { [delegate] in

        delegate.didTapToComposeNewMessage()

      }).disposed(by: disposeBag)

    sortButton.rx.tap
      .subscribe(onNext: { [delegate] in

        delegate.didTapToChangeInboxType()

      }).disposed(by: disposeBag)

  }

  // MARK: - View Configuration

  private func setupNavigationItems() {
    navigationItem.rightBarButtonItems = [addButton, sortButton]
  }

  // MARK: - Actions

  private func loadMessages() {

    shouldAutoLoad = false

    firstly {
      model.getMessages()

    }.done { messages in
      if messages.isEmpty {
        Toast.show("Looks like there's no messages here.", duration: 3)

      } else {
        self.node.reloadData()
      }

    }.catch { _ in
      Toast.show("Unable to fetch messages", duration: 3)

    }.finally {
      self.shouldAutoLoad = true
      self.node.refreshControl?.endRefreshing()
    }

  }

  func deleteRow(at indexPath: IndexPath) {
    node.deleteRows(at: [indexPath], with: .automatic)
  }

}
