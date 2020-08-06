//
//  SettingsViewController+Form.swift
//  Reddit
//
//  Created by made2k on 5/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Eureka

extension SettingsViewController {

  func setupForm(_ form: Form) {
    setupSubredditsSection(form)
    setupSearchSection(form)
    setupAppSettingsSection(form)
    setupAboutSection(form)
  }

  private func setupSubredditsSection(_ form: Form) {

    form +++ Section(R.string.settings.subredditSectionTitle())

      <<< LabelRow() { row in
        row.title = R.string.settings.goToSubreddit()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        self.delegate.didSelectGoToSubreddit()
      }

  }

  private func setupSearchSection(_ form: Form) {

    form +++ Section(R.string.settings.searchSectionTitle())
      <<< LabelRow() { row in
        row.title = R.string.settings.performSearch()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        self.delegate.didSelectSearch()
      }

  }

  private func setupAppSettingsSection(_ form: Form) {

    form +++ Section(R.string.settings.appSettingsSectionTitle())

      <<< IconRow() { row in
        row.cell.label.text = R.string.settings.general()
        row.cell.icon.image = R.image.icon_settingsColor()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        self.delegate.didSelectGeneralSettings()
      }

      <<< IconRow() { row in
        row.cell.label.text = R.string.settings.appearance()
        row.cell.icon.image = R.image.icon_settings_appearance()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        self.delegate.didSelectAppearanceSettings()
      }

      <<< IconRow(TagIdentifier.themeIndexRow) { row in
        row.cell.label.text = R.string.settings.theme()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        let theme = ThemeSettingsViewController()
        self.show(theme, sender: self)
      }

      <<< IconRow() { row in
        row.cell.label.text = R.string.settings.passcode()
        let icon = Security.shared.hasFaceId ? R.image.settings_FaceID() : R.image.settings_TouchID()
        row.cell.icon.image = icon
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        let passcode = PasscodeSettingsViewController()
        self.show(passcode, sender: self)
      }

      <<< IconRow() { row in
        row.cell.label.text = R.string.settings.filters()
        row.cell.icon.image = R.image.settings_Filter()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        let filter = FilterTypeViewController()
        self.show(filter, sender: self)
      }

      <<< IconRow() { row in
        row.cell.label.text = R.string.settings.accounts()
        row.cell.icon.image = R.image.settings_Account()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        let accounts = AccountsViewController.fromStoryboard()
        self.show(accounts, sender: self)
      }

  }

  private func setupAboutSection(_ form: Form) {

    let appVersion = UIApplication.shared.marketingVersion ?? "??"
    let buildNumber = UIApplication.shared.buildNumber ?? "??"
    let hash = UIApplication.shared.gitHash

    let hashString = hash != nil ? " \(hash.unsafelyUnwrapped)" : ""

    let footerText = "Advanced\n\(appVersion) (\(buildNumber))\(hashString)"

    form +++ Section(header: R.string.settings.aboutSectionTitlte(), footer: footerText)

      <<< LabelRow() { row in
        row.title = R.string.settings.subreddit()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { _, _ in
        SplitCoordinator.current.openSubreddit(subredditName: "AdvancedApp")
      }

      <<< LabelRow() { row in
        row.title = R.string.settings.openSource()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        let vc = LicenseViewController()
        self.show(vc, sender: self)
      }

      <<< LabelRow() { row in
        row.title = R.string.settings.privacy()
        row.cell.accessoryType = .disclosureIndicator

      }.onCellSelection { [unowned self] _, _ in
        let vc = PrivacyViewController()
        self.show(vc, sender: self)
      }

  }

}
