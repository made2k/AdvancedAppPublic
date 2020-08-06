//
//  SideMenu+Subreddit.swift
//  Reddit
//
//  Created by made2k on 1/23/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Eureka
import Haptica
import PromiseKit
import SwifterSwift
import UIKit

extension SideMenuViewController {

  func addSubredditCells() {

    guard let subredditName = SubredditFinder.activeName else { return }
    guard let subreddit = SubredditFinder.activeModel else { return }
    guard subreddit.isUserSubreddit == false else { return }

    let isSignedIn = AccountModel.currentAccount.value.isSignedIn

    let subscribeString = R.string.sideMenu.subscribe()
    let unsubscribeString = R.string.sideMenu.unsubscribe()

    let section = Section(subredditName)

    form +++ section

    section <<< LabelRow() { row in
      row.title = subreddit.subscribed ? unsubscribeString : subscribeString
      row.hidden = Condition(booleanLiteral: isSignedIn == false)

    }.onCellSelection { _, row in
      let newSubscribe = !subreddit.subscribed
      let promise = newSubscribe ? subreddit.subscribe() : subreddit.unsubscribe()
      Haptic.selection.generate()

      firstly {
        promise

      }.done {
        row.title = newSubscribe ? unsubscribeString : subscribeString
        row.updateCell()
        row.reload()
      }.catch(self.handle)
    }

    section <<< LabelRow() { row in
      row.title = R.string.sideMenu.submit()
      row.hidden = Condition(booleanLiteral: isSignedIn == false)

    }.onCellSelection { _, _ in
      guard let subreddit = subreddit.subreddit else { return }
      self.delegate?.dismiss { [subreddit] in
        let presenter = SplitCoordinator.current.splitViewController
        SubmissionCoordinator(presenter: presenter, subreddit: subreddit, autoSave: nil).start()
      }
    }

    section <<< LabelRow() { row in
      row.title = R.string.sideMenu.sidebar()
      let hasSideBar = subreddit.subreddit?.subredditDescription.isNotEmpty == true
      row.hidden = Condition(booleanLiteral: hasSideBar == false)

    }.onCellSelection { _, _ in
      let vc = SideBarViewController(model: subreddit)
      self.delegate?.dismissAndShow(vc)
    }

  }

}
