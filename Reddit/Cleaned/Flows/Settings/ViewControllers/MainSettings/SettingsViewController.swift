//
//  SettingsViewController.swift
//  Reddit
//
//  Created by made2k on 3/7/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Eureka
import RxSwift
import UIKit

final class SettingsViewController: SettingsBaseViewController {

  struct TagIdentifier {
    static let themeIndexRow = UUID().uuidString
  }

  let delegate: SettingsViewControllerDelegate
  private let disposeBag = DisposeBag()

  // MARK: - Initialization

  init(delegate: SettingsViewControllerDelegate) {
    self.delegate = delegate

    super.init()

    self.title = R.string.settings.settingsTitle()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    hideBackButtonTitle()
    setupForm(form)
    setupBindings()
  }

  // Bindings
  
  private func setupBindings() {
    
    SplitCoordinator.currentObserver
    .map { $0?.interfaceObserver }
    .replaceNilWith(Observable<UIUserInterfaceStyle>.just(.unspecified))
    .flatMap { $0 }
    .distinctUntilChanged()
      .subscribe(onNext: { [weak self] in
        self?.updateThemeCell(interfaceStyle: $0)
      }).disposed(by: disposeBag)

  }

  // MARK: - Form Updates

  private func updateThemeCell(interfaceStyle: UIUserInterfaceStyle) {
    guard let themeCell = form.rowBy(tag: TagIdentifier.themeIndexRow) as? IconRow else { return }
    themeCell.cell.icon.image = interfaceStyle == .light ?
      R.image.settings_Theme_Light() :
      R.image.settings_Theme_Dark()
  }

}
