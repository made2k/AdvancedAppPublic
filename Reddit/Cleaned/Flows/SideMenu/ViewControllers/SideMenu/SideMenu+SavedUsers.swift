//
//  SideMenu+SavedUsers.swift
//  Reddit
//
//  Created by made2k on 7/12/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Eureka
import PromiseKit

extension SideMenuViewController {

  func addSavedUserCells() {

    let currentUser = Keychain.shared.preferredUsername
    let availableUsers = Keychain.shared.userNames.filter { $0 != currentUser }

    guard availableUsers.isNotEmpty else { return }

    let section = Section("Saved Accounts")

    form +++ section

    for user in availableUsers {

      section <<< LabelRow() { row in
        row.title = user

      }.onCellSelection { [weak self] _, _ in
        self?.signIn(as: user)
      }

    }

  }

  private func signIn(as username: String) {

    Overlay.shared.showProcessingOverlay(status: "Signing in as \(username)")

    firstly {
      after(seconds: 0.4)

    }.then {
      Keychain.shared.setPreferedUsername(username)

    }.done { _ in
      self.delegate?.dismiss { }
      Overlay.shared.hideProcessingOverlay()

    }.catch { _ in
      Overlay.shared.flashErrorOverlay("Error signing in")
    }

  }

}
