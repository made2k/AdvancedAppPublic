//
//  SideMenu+User.swift
//  Reddit
//
//  Created by made2k on 4/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Eureka
import Logging
import PromiseKit
import UIKit

extension SideMenuViewController {
  
  func addUserCells() {

    let userText =
      AccountModel.currentAccount.value.username ??
      R.string.sideMenu.defaultUserTitle()

    let isSignedIn = AccountModel.currentAccount.value.isSignedIn
    let isNotSignedIn = !isSignedIn

    form +++ Section(userText)

      // Sign In
      <<< LabelRow() { row in
        row.title = R.string.sideMenu.signIn()
        row.hidden = Condition(booleanLiteral: isSignedIn)
        
      }.onCellSelection { _, _ in
        let controller = AccountsViewController.fromStoryboard()
        self.delegate?.dismissAndShow(controller)
      }

      // Profile
      <<< LabelRow() { row in
        row.title = R.string.sideMenu.profile()
        row.hidden = Condition(booleanLiteral: isNotSignedIn)
        
      }.onCellSelection { _, _ in
        guard let username = AccountModel.currentAccount.value.username else { return }
        self.delegate?.dismiss {
          LinkHandler.openRedditUser(userName: username)
        }
      }

      <<< LabelRow() { row in
        row.title = R.string.sideMenu.submitted()
        row.hidden = Condition(booleanLiteral: isNotSignedIn)

      }.onCellSelection { _, _ in
        self.showSubmitted()
      }

      <<< LabelRow() { row in
        row.title = R.string.sideMenu.saved()
        row.hidden = Condition(booleanLiteral: isNotSignedIn)

      }.onCellSelection { _, _ in
        self.showSaved()
      }

      <<< LabelRow() { row in
        row.title = R.string.sideMenu.hidden()
        row.hidden = Condition(booleanLiteral: isNotSignedIn)

      }.onCellSelection { _, _ in
        self.showHidden()
      }
      
      <<< LabelRow() { row in
        row.title = R.string.sideMenu.logOut()
        row.hidden = Condition(booleanLiteral: isNotSignedIn)
        
      }.onCellSelection { _, _ in
        guard let preferredUser = AccountModel.currentAccount.value.username else { return }
        Keychain.shared.remove(username: preferredUser)
        self.delegate?.dismiss(completion: {})
    }
  }

  private func showSubmitted() {
    
    firstly {
      AccountModel.currentAccount.value.getUserModel()

    }.map {
      return UserSubmissionModel(user: $0.user)

    }.done {
      let controller = UserListingsViewController(model: $0)
      controller.title = R.string.sideMenu.submitted()
      self.delegate?.dismissAndShow(controller)

    }.catch {
      log.error("error loading user", error: $0)
      Overlay.shared.flashErrorOverlay("Failed to load user")
    }

  }

  private func showSaved() {

    firstly {
      AccountModel.currentAccount.value.getUserModel()

    }.map {
      return UserSavedModel(user: $0.user)

    }.done {
      let controller = UserListingsViewController(model: $0)
      controller.title = R.string.sideMenu.saved()
      self.delegate?.dismissAndShow(controller)

    }.catch {
      log.error("error loading user", error: $0)
      Overlay.shared.flashErrorOverlay("Failed to load user")
    }

  }

  private func showHidden() {

    firstly {
      AccountModel.currentAccount.value.getUserModel()

    }.map {
      return UserHiddenModel(user: $0.user)

    }.done {
      let controller = UserListingsViewController(model: $0)
      controller.title = R.string.sideMenu.hidden()
      self.delegate?.dismissAndShow(controller)

    }.catch {
      log.error("error loading user", error: $0)
      Overlay.shared.flashErrorOverlay("Failed to load user")
    }

  }

}
