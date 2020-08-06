//
//  SideBarViewController.swift
//  Reddit
//
//  Created by made2k on 1/20/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit
import SideMenu

class SideBarViewController: ASViewController<ASTableNode> {
  
  private var model: SubredditModel?
  private lazy var errorView = SideBarErrorBackgroundView()

  private var hasAllInfo: Bool {
    return model?.subreddit != nil && model?.activeUserCount.value != nil
  }
  
  // MARK: - Initialization
  
  init(subredditName: String) {
    let table = ASTableNode(style: .plain)
    super.init(node: table)
    
    commonInit(attemptRefresh: false)
    
    firstly {
      SubredditModel.verifySubredditExists(path: subredditName)
      
    }.done {
      self.model = $0
      
    }.done {
      self.refreshIfNeeded()
      
    }.catch { _ in
      self.node.view.backgroundView = self.errorView
    }
  }
  
  init(model: SubredditModel) {
    self.model = model
    
    let table = ASTableNode(style: .plain)
    super.init(node: table)
    commonInit(attemptRefresh: true)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func commonInit(attemptRefresh: Bool) {
    node.dataSource = self
    node.allowsSelection = false
    node.hideEmptyCells()
    node.backgroundColor = .systemBackground
    
    title = R.string.sideBar.title()
    
    if attemptRefresh {
      refreshIfNeeded()
    }
  }
  
  // MARK: - Helpers
  
  func refreshIfNeeded() {
    guard let model = model else { return }
    guard hasAllInfo == false else  {
      return node.reloadData()
    }
    
    firstly {
      model.refreshInfo()
      
    }.done { _ in
      self.node.reloadData()
      
    }.catch { _ in
      self.node.view.backgroundView = self.errorView
    }
  }
  
  private func linkTapped(_ url: URL) {
    
    if SideMenuManager.default.isActive {
      SideMenuManager.default.dismiss {
        LinkHandler.handleUrl(url)
      }
      
    } else {
      LinkHandler.handleUrl(url)
    }
  }
  
}

// MARK: - ASTableDataSource

extension SideBarViewController: ASTableDataSource {
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {

    // Always show loading cell
    guard hasAllInfo else { return 1 }
    guard let subreddit = model?.subreddit else { return 1 }

    return subreddit.subredditDescriptionHtml.isNotNilOrEmpty ? 2 : 1
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

    guard
      let model = model,
      let subreddit = model.subreddit,
      hasAllInfo else {
      return { LoadingActivityCellNode() }
    }

    
    if indexPath.row == 0 {
      return {
        SidebarHeaderNode(subredditModel: model)
      }
    }
    
    return {
      let node = HTMLCellNode(html: subreddit.subredditDescriptionHtml,
                          layoutInsets: UIEdgeInsets(top: 12, left: 12, bottom: 16, right: 12),
                          onLinkTapped: self.linkTapped)
      node.textNode.lineHeightMultiple = 1.6
      
      return node
    }
  }
}
