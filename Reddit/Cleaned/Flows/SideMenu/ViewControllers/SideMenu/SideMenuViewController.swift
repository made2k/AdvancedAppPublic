//
//  SideMenuViewController.swift
//  Reddit
//
//  Created by made2k on 1/20/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Eureka
import RxSwift
import UIKit

final class SideMenuViewController: FormViewController {

  // Run once
  private static let registerCells: Void = {

    LabelRow.defaultCellUpdate = { cell, row in
      cell.backgroundColor = .secondarySystemGroupedBackground
      cell.textLabel?.textColor = .label
      cell.textLabel?.font = Settings.fontSettings.fontValue
      cell.detailTextLabel?.textColor = .secondaryLabel
    }

    SwitchRow.defaultCellUpdate = { cell, row in
      cell.backgroundColor = .secondarySystemGroupedBackground
      cell.textLabel?.textColor = .label
      cell.textLabel?.font = Settings.fontSettings.fontValue
    }

    IconRow.defaultCellUpdate = { cell, row in
      cell.label.textColor = .label
      cell.backgroundColor = .secondarySystemGroupedBackground
      cell.label.font = Settings.fontSettings.fontValue
    }

    ListCheckRow<Bool>.defaultCellUpdate = { cell, _ in
      cell.backgroundColor = .secondarySystemGroupedBackground
      cell.selectedBackgroundView = SelectedCellBackgroundView()
      cell.textLabel?.textColor = .label
      cell.textLabel?.font = Settings.fontSettings.fontValue
    }

  }()

  private let disposeBag = DisposeBag()
  private(set) weak var delegate: SideMenuViewControllerDelegate?

  // MARK: - Initialization

  init(delegate: SideMenuViewControllerDelegate) {
    self.delegate = delegate
    super.init(style: .grouped)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    SideMenuViewController.registerCells
    tableView.backgroundColor = .systemGroupedBackground
    tableView.separatorColor = .separator
    setupBindings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadSideMenu()
  }

  // MARK: - Form Setup

  private func reloadSideMenu() {
    UIView.performWithoutAnimation {

      if form.count > 0 {
        form.removeAll()
      }
      
      addSubredditCells()
      addListingCells()
      addGeneralCells()
      addUserCells()
      addSavedUserCells()
    }
  }

  // MARK: - Bindings

  private func setupBindings() {

    AccountModel.currentAccount
      .distinctUntilChanged { $0.username == $1.username }
      .filter { _ in SplitCoordinator.current != nil }
      .skip(1)
      .subscribe(onNext: { [unowned self] _ in
        self.reloadSideMenu()
      }).disposed(by: disposeBag)

  }

}
