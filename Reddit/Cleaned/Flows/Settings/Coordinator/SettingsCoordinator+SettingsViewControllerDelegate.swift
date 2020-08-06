//
//  SettingsCoordinator+SettingsViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 5/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

extension SettingsCoordinator: SettingsViewControllerDelegate {

  func didSelectGoToSubreddit() {

    guard let navigation = navigation else { return }

    let coordinator = SubredditListCoordinator(navigation: navigation,
                                               tableStyle: .grouped)
    coordinator.start()
  }

  func didSelectSearch() {

    guard let navigation = navigation else { return }

    SearchCoordinator(navigation: navigation).start()
  }

  func didSelectGeneralSettings() {

    guard let navigation = navigation else { return }

    let controller = GeneralSettingsViewController(delegate: self)
    navigation.pushViewController(controller)
  }
  
  func didSelectAppearanceSettings() {
    let controller = AppearanceSettingsViewController(delegate: self)
    navigation?.pushViewController(controller)
  }

}
