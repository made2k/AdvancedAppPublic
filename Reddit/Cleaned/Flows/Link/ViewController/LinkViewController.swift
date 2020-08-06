//
//  LinkViewController.swift
//  Reddit
//
//  Created by made2k on 10/29/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit
import RedditAPI
import RxSwift
import SideMenu
import Then
import UIKit

final class LinkViewController: ASViewController<ASDisplayNode> {

  enum LoadState {
    case noContent
    case notLoaded
    case loaded
  }
  
  private let navigatorButtonSize: CGFloat = 30

  private var loadingView: LinkNotLoadedView?
  private lazy var navigatorButton: UIButton = {
    return UIButton().then {
      $0.addTargetClosure { [weak self] in
        self?.commentNavigatorButtonPressed()
      }
      $0.backgroundColor = UIColor(hex: "3a88f0")
      $0.setBackgroundImage(R.image.icon_drop_arrows(), for: .normal)
      $0.contentMode = .scaleAspectFit
      $0.tintColor = .white
      $0.layer.cornerRadius = navigatorButtonSize / 2
      $0.adjustsImageWhenHighlighted = false
    }
  }()
  private let sortButton = UIBarButtonItem(
    image: Settings.defaultCommentSort.icon.barButtonSafe,
    style: .plain)

  let tableNode = ASTableNode(style: .plain).then {
    $0.backgroundColor = .systemBackground
    $0.separatorStyle = .none
    $0.hideEmptyCells()
  }

  var model: LinkModel? {
    didSet {
      guard let model = model, isViewLoaded else { return }
      model.markRead()
      setupBindings(model)
      loadingView?.fadeOutAndRemove(duration: 0.25)
    }
  }
  var link: Link? { return model?.link }
  /// Handed upon initialization. Indicates if we don't
  /// have a model, if it's loading or not.
  private let modelWouldBeLoading: Bool

  /// When this is set, if the loading view is displayed
  /// the message here will be displayed on that view.
  var errorMessage: String? {
    didSet {
      guard let message = errorMessage else { return }
      loadingView?.titleLabel.text = message
      loadingView?.hideActivity()
    }
  }

  // Strong reference to keep the delegate until
  // the view controller is released
  internal let delegate: LinkViewControllerDelegate

  private var disposeBag = DisposeBag()

  // MARK: - Initialization

  init(model: LinkModel?, modelWouldBeLoading: Bool, delegate: LinkViewControllerDelegate) {
    self.delegate = delegate
    self.model = model
    self.modelWouldBeLoading = modelWouldBeLoading

    tableNode.dataSource = delegate
    tableNode.delegate = delegate

    super.init(node: ASDisplayNode(automanaged: true))

    node.layoutSpecBlock = { [unowned self] _, _ -> ASLayoutSpec in
      return ASWrapperLayoutSpec(layoutElement: self.tableNode)
    }

    tableNode.addPullToRefresh { [unowned self] in self.refreshControlDidChange($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    hideBackButtonTitle()
    addShareNavigationButton()
    setupCommentNavigator()
    setupSideMenuGesture()

    if model?.commentTree == nil {
      delegate.loadComments()
    }

    if let model = model {
      setupBindings(model)

    } else {
      addLoadingView(isLoading: modelWouldBeLoading)
    }

  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    delegate.viewDidDisappear()
  }

  // MARK: - Bindings

  private func setupBindings(_ model: LinkModel) {
    disposeBag = DisposeBag()

    model.commentSort
      .map { $0.icon.barButtonSafe }
      .bind(to: sortButton.rx.image)
      .disposed(by: disposeBag)

    sortButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.delegate.showSortSelection()
      }).disposed(by: disposeBag)

  }
  
  // MARK: - View Configuration
  
  private func addShareNavigationButton() {
    let button = UIBarButtonItem(image: R.image.iconEllipsisCircleSmall()?.barButtonSafe, style: .plain) { [weak self] _ in
      self?.showSideMenu()
    }

    navigationItem.rightBarButtonItems = [button, sortButton]
  }
  
  private func setupCommentNavigator() {
    
    navigatorButton.imageEdgeInsets = UIEdgeInsets(inset: 16)
    navigatorButton.removeFromSuperview()
    navigatorButton.snp.removeConstraints()
    
    let side = Settings.commentNavigatorPosition
    guard side != .none else { return }
    
    view.addSubview(navigatorButton)

    navigatorButton.snp.makeConstraints { make in
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
      make.width.equalTo(navigatorButton.snp.height)
      make.height.equalTo(navigatorButtonSize)
    }
    
    switch side {
    case .right, .none:
      navigatorButton.snp.makeConstraints { $0.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-32) }
    case .left:
      navigatorButton.snp.makeConstraints { $0.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(32) }
    case .center:
      navigatorButton.snp.makeConstraints { $0.centerX.equalToSuperview() }
    }

  }
  
  private func setupSideMenuGesture() {
    SideMenuManager.default.addAndPersistGesture(to: view, for: .right)
  }

  // MARK: - Actions

  private func refreshControlDidChange(_ control: UIRefreshControl) {

    firstly {
      delegate.clearFocus()

    }.ensure {
      control.endRefreshing()

    }.cauterize()

  }
  
  private func showSideMenu() {
    guard let rightMenu = SideMenuManager.default.rightMenuNavigationController else { return }
    present(rightMenu)
  }
  
  private func addLoadingView(isLoading: Bool) {
    let loadingView = LinkNotLoadedView(loading: isLoading)
    self.loadingView = loadingView
    
    view.addSubview(loadingView)
    
    loadingView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func scrollToCommentId(_ commentId: String) {
    guard let tree = model?.commentTree else { return }
    guard let index = tree.allComments.firstIndex(where: { $0.id == commentId }) else { return }

    let animated = node.isInDisplayState && loadingView == nil
    let indexPath = IndexPath(row: index, section: 1)
    tableNode.scrollToRow(at: indexPath, at: .top, animated: animated)
  }

  // MARK: - Table Forwards

  func reloadData() {
    tableNode.reloadData()
  }

  func reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
    tableNode.reloadSections(sections, with: animation)
  }

  func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
    tableNode.reloadRows(at: indexPaths, with: animation)
  }

  func performBatchUpdates(_ updates: ((ASTableNode) -> Void)?, completion: ((Bool) -> Void)? = nil) {
    let updateBlock: () -> Void = {
      updates?(self.tableNode)
    }
    tableNode.performBatchUpdates(updateBlock, completion: completion)
  }
  
}
