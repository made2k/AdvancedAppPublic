//
//  ListingsViewControllerV2.swift
//  Reddit
//
//  Created by made2k on 4/6/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import SideMenu
import UIKit

class ListingsViewController: ASViewController<ASDisplayNode> {

  enum ListingsDisplayState {
    case preloaded
    case loaded
  }

  let tableNode = ASTableNode(style: .plain).then {
    $0.automaticallyAdjustsContentOffset = true
    $0.backgroundColor = .systemBackground
    $0.separatorStyle = .none
    $0.hideEmptyCells()
    $0.keyboardDismissMode = .onDrag
  }

  var displayState = ListingsDisplayState.preloaded {
    didSet {
      let view: UIView? = displayState == .loaded ? nil : EmptyTableView()
      tableNode.view.backgroundView = view
    }
  }

  // MARK: - View Objects

  let navigationTitleView = DropdownTitleTextField()

  lazy var hideReadButton: UIButton = {
    let button = UIButton().then {
      $0.tintColor = R.color.offWhite()
      $0.backgroundColor = R.color.advancedBlue()
      $0.setImage(R.image.icon_hide(), for: .normal)
      $0.imageEdgeInsets = UIEdgeInsets(inset: 10)
      $0.imageView?.contentMode = .scaleAspectFit
      $0.adjustsImageWhenHighlighted = false
      $0.addHaptic(.button, forControlEvents: .touchDown)

      $0.layer.cornerRadius = 20
    }
    return button
  }()

  lazy var unreadBarButtonItem: UIBarButtonItem = {

    return UIBarButtonItem(image: R.image.icon_mail()?.barButtonSafe, style: .plain) { [weak self] _ in
      InboxCoordinator(split: SplitCoordinator.current).start()
    }

  }()

  lazy var sortBarButtonItem: UIBarButtonItem = {
    return UIBarButtonItem(title: nil, style: .plain) { [weak self] _ in
      self?.delegate?.sortButtonPressed()
    }
  }()

  lazy var settingsBarButtonItem: UIBarButtonItem = {
    let item = UIBarButtonItem(title: nil, style: .plain) { [weak self] _ in
      self?.delegate?.settingsButtonPressed()
    }
    item.image = R.image.iconEllipsisCircleSmall()?.barButtonSafe
    return item
  }()

  // MARK: - Misc Properties

  override var title: String? {
    didSet { navigationTitleView.text = title }
  }

  // TODO: Try getting this private
  var delegate: ListingsViewControllerDelegate?
  let disposeBag = DisposeBag()
  var postLoadDisposeBag = DisposeBag()

  // MARK: - Init

  init(delegate: ListingsViewControllerDelegate) {
    self.delegate = delegate

    let node = ASDisplayNode(automanaged: true)
    node.backgroundColor = .systemBackground

    super.init(node: node)

    node.layoutSpecBlock = { [unowned self] in
      return self.layoutSpecThatFits($0, constrainedSize: $1)
    }

    navigationItem.largeTitleDisplayMode = .always

    tableNode.batchFetchingDelegate = delegate

    navigationItem.leftItemsSupplementBackButton = true
    hideBackButtonTitle()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    addHideReadAsSubview()
    configureQuickSwitch()

    tableNode.addPullToRefresh { [unowned self] in self.refreshControlDidChange($0) }

    navigationItem.titleView = navigationTitleView

    SideMenuManager.default.addAndPersistGesture(to: view, for: .right)

    configureRightBarButtonItems(showOptions: true)
    setupBindings()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.prefersLargeTitles = Settings.preferLargeTitles
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentSwipeAlertIfNeeded()
  }

  // MARK: - Actions

  func configureRightBarButtonItems(showOptions: Bool) {
    if showOptions {
      navigationItem.rightBarButtonItems = [settingsBarButtonItem, sortBarButtonItem]

    } else {
      navigationItem.rightBarButtonItems = [sortBarButtonItem]
    }
  }

  private func refreshControlDidChange(_ control: UIRefreshControl) {
    delegate?.refresh(with: control)
  }

  func previewTypeToggled() {
    delegate?.togglePreviewTypeForSubreddit()
  }

  func listingDisplayWasSet(_ display: ListingDisplay) {
    setupListingBindings(display)
  }

  // MARK: - Layout

  func layoutSpecThatFits(_ node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASWrapperLayoutSpec(layoutElement: tableNode)
  }

}

extension ListingsViewController {

  func reloadData(maintainScrollPosition: Bool = false) {
    tableNode.reloadData(maintainScrollPosition: maintainScrollPosition)
  }

}
