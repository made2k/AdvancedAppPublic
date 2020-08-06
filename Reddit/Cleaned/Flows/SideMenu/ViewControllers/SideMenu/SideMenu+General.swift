//
//  SideMenu+General.swift
//  Reddit
//
//  Created by made2k on 4/18/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Eureka
import Haptica
import UIKit

extension SideMenuViewController {
  
  func addGeneralCells() {

    form +++ Section(R.string.sideMenu.generalSectionTitle())

      // Settings
      <<< LabelRow() { row in
        row.title = R.string.sideMenu.settings()
        row.hidden = Condition(booleanLiteral: SplitCoordinator.current.isShowing(SettingsViewController.self))
        
      }.onCellSelection { [unowned self] _, _ in
        self.delegate?.dismissAndShowSettings()
      }

      // Go To Subreddit
      <<< LabelRow() { row in
        row.title = R.string.sideMenu.goToSubreddit()
        row.hidden = Condition(booleanLiteral: SplitCoordinator.current.isShowing(SubredditViewController.self))
        
      }.onCellSelection { [unowned self] _, _ in
        self.delegate?.dismissAndShowSubredditList()
      }

      // Messages
      <<< LabelRow() { row in
        row.title = R.string.sideMenu.messages()
        row.value = InboxWatcher.shared.unreadCount.value > 0 ? R.string.sideMenu.unreadCount(InboxWatcher.shared.unreadCount.value) : nil
        let isSignedIn = AccountModel.currentAccount.value.isSignedIn
        row.hidden = Condition(booleanLiteral: isSignedIn == false)

      }.onCellSelection { [unowned self] _, _ in
        self.delegate?.dismiss {
          InboxCoordinator(split: SplitCoordinator.current).start()
        }
      }

      // Search
      <<< LabelRow() { row in
        row.title = R.string.sideMenu.search()
        row.hidden = Condition(booleanLiteral: SplitCoordinator.current.isShowing(SearchViewController.self))
        
      }.onCellSelection { [unowned self] _, _ in
        self.delegate?.dismissAndShowSearch()
    }
  }
  
}
