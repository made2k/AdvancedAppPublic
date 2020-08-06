//
//  UserListingsViewController.swift
//  Reddit
//
//  Created by made2k on 6/12/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit

class UserListingsViewController: ASViewController<ASTableNode> {
  
  let model: UserListingModel
  
  init(model: UserListingModel) {
    
    self.model = model
    
    let tableNode = ASTableNode(style: .plain)
    tableNode.backgroundColor = .systemBackground
    tableNode.separatorStyle = .none
    
    super.init(node: tableNode)
    
    title = title ?? model.title
    
    model.listingsDisplayDelegate = self
    model.bind(to: tableNode)
    tableNode.batchFetchingDelegate = self
    tableNode.addPullToRefresh { [unowned self] in
      self.refresh($0)
    }

    hideBackButtonTitle()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {

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
  
  private func refresh(_ control: UIRefreshControl) {
    firstly {
      model.reload()
      
    }.catch { _ in
      Toast.show("Error loading data", duration: 3)
      
    }.finally {
      control.endRefreshing()
    }
  }
}

extension UserListingsViewController: ASBatchFetchingDelegate {
  
  func shouldFetchBatch(withRemainingTime remainingTime: TimeInterval, hint: Bool) -> Bool {
    guard model.paginator.hasMore else { return false }
    return hint || remainingTime < 1.5
  }
  
}

extension UserListingsViewController: Presentable {
  
  var presentingType: PresentingType {
    return PresentingType.primary
  }
  
}

extension UserListingsViewController: ListingDisplayDelegate {
  
  func didOpenLink(_ linkModel: LinkModel) {
    SplitCoordinator.current.didOpenLink(linkModel)
  }

}
