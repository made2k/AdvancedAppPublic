//
//  UserOverviewViewController.swift
//  Reddit
//
//  Created by made2k on 11/12/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit

import Utilities

import AsyncDisplayKit
import PromiseKit
import RedditAPI

// TODO: iOS 13 add context menu to the cells here
class UserOverviewViewController: ASViewController<ASTableNode> {

  enum UserRows: Int {
    case submitted = 1
    case comments
    case saved
    case hidden
    case upvoted
    case downvoted

    static var accountRows: [UserRows] {
      return [.submitted, .comments, .saved, .hidden, .upvoted, .downvoted]
    }

    static var userRows: [UserRows] {
      return [.submitted, .comments]
    }
  }

  let userName: String
  let tableNode: ASTableNode
  
  var overviewDataSource: [Thing] = []
  
  private(set) var model: UserModel?
  private(set) var trophies: [Trophy] = []
  private(set) var subreddits: [KarmaListSubreddit] = []

  init(userName: String) {
    self.userName = userName
   
    self.tableNode = ASTableNode(style: .grouped)
    super.init(node: self.tableNode)
    
    commonInit()
    
    loadOverview()
  }
  
  init(model: UserModel) {
    self.model = model
    self.userName = model.username
    
    self.tableNode = ASTableNode(style: .grouped)
    super.init(node: self.tableNode)

    commonInit()
  }
  
  private func commonInit() {
    title = userName
    
    tableNode.dataSource = self
    tableNode.delegate = self

    tableNode.backgroundColor = .systemGroupedBackground
    
    if AccountModel.currentAccount.value.isSignedIn {
      let composeButton = UIBarButtonItem(image: R.image.icon_sent()?.barButtonSafe, landscapeImagePhone: nil, style: .done, target: self, action: #selector(composeMessage))
      navigationItem.rightBarButtonItem = composeButton
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if self.model == nil {
      tableNode.view.backgroundView = EmptyTableView()
    }
  }
  
  @objc func composeMessage() {
    guard AccountModel.currentAccount.value.isSignedIn else { return }
    let inboxModel = AccountModel.currentAccount.value.inboxModel
    
    let compose = ComposeMessageViewController(model: inboxModel, username: model?.username)
    let nav = NavigationController(controllers: compose)
    nav.modalPresentationStyle = .formSheet
    
    present(nav)
  }
  
  func loadOverview() {
    
    firstly {
      UserCache.shared.loadIfNeeded(userName)
      
    }.get {
      self.model = $0
      self.tableNode.view.backgroundView = nil
      
    }.then { model -> Promise<(UserModel, [Trophy])> in
      model.loadTrophies().map { (model, $0) }
      
    }.then { (model, trophies) -> Promise<[KarmaListSubreddit]> in
      self.trophies = trophies
      return model.loadKarmaSubreddits()
      
    }.done {
      self.subreddits = $0
      
    }.ensure {
      self.tableNode.reloadData()
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let selectedIndex = tableNode.indexPathForSelectedRow {
      tableNode.deselectRow(at: selectedIndex, animated: true)
    }
  }
}

extension UserOverviewViewController: Presentable {

  var presentingType: PresentingType {
    return .primary
  }

}
