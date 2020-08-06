//
//  UserCommentsViewController.swift
//  Reddit
//
//  Created by made2k on 6/12/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI

// TODO: iOS 13 add context menu to the cells here
class UserCommentsViewController: ASViewController<ASTableNode> {
  let model: UserCommentsViewModel
  
  init(user: User) {
    let tableNode = ASTableNode(style: .plain)
    tableNode.backgroundColor = .systemGroupedBackground
    model = UserCommentsViewModel(user: user)
    
    super.init(node: tableNode)
    
    title = title ?? user.name
    
    tableNode.dataSource = self
    tableNode.batchFetchingDelegate = self
    tableNode.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    node.addPullToRefresh { [unowned self] in self.refresh($0) }
    node.view.backgroundView = EmptyTableView()
    node.view.tableFooterView = UIView()

    model.loadPosts().done { _ in
      self.node.reloadData()
      self.node.view.backgroundView = nil
      
    }.catch { _ in
      Toast.show("Error loading data", duration: 3)
    }
  }
  
  @objc private func refresh(_ control: UIRefreshControl) {
    model.reset()

    model.loadPosts().done { _ in
      self.node.reloadData()
      
    }.catch { _ in
      Toast.show("Error loading data", duration: 3)

    }.finally {
      control.endRefreshing()
    }
  }
}

extension UserCommentsViewController: ASTableDataSource {
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return model.comments.count
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let comment = model.comments[indexPath.section]
    
    if indexPath.row == 0 {
      return {
        UserCommentLinkCell(comment: comment)
      }
    }
    
    return {
      let model = CommentModel(comment, parent: nil)
      let node = OverviewCommentCellNode(model: model)
      return node
    }
  }

}

extension UserCommentsViewController: ASTableDelegate {
  
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    tableNode.deselectRow(at: indexPath, animated: true)

    let comment = model.comments[indexPath.section]
    guard let url = comment.linkPermalink else { return }

    if let match = SubredditLinkMatcher.match(url, focusingId: comment.id) {
      LinkHandler.openRedditLink(match)
    }

  }
}

extension UserCommentsViewController: ASBatchFetchingDelegate {
  
  func shouldFetchBatch(withRemainingTime remainingTime: TimeInterval, hint: Bool) -> Bool {
    return model.canLoadMore && remainingTime < 1.5
  }
  
  func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
    guard model.canLoadMore else { return context.completeBatchFetching(true) }
    
    model.loadPosts().done(insertIntoTable).catch { _ in
      Toast.show("Trouble loading more posts, will try again soon", duration: 2)
      
      }.finally {
        context.completeBatchFetching(true)
    }
  }
  
  // TODO: DRY in ListingsViewController
  private func insertIntoTable(comments: [Comment]) {
    
    let oldCount = model.comments.count - comments.count
    var indexes = [Int]()
    
    for i in oldCount..<model.comments.count {
      indexes.append(i)
    }
    
    DispatchQueue.main.async {
      self.node.insertSections(IndexSet(indexes), with: .automatic)
    }
  }
}

extension UserCommentsViewController: Presentable {
  var presentingType: PresentingType {
    return PresentingType.detail
  }
}
