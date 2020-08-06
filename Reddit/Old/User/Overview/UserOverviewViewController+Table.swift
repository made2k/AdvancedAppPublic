//
//  UserOverviewViewController+Table.swift
//  Reddit
//
//  Created by made2k on 11/12/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit

extension UserOverviewViewController: ASTableDataSource, ASTableDelegate {
  
  // MARK: - Section management
  
  var trophySection: Int? {
    guard trophies.count > 0 else { return nil }
    return 1
  }
  
  var activeSection: Int? {
    guard subreddits.count > 0 else { return nil }
    if trophySection == nil {
      return 1
    }
    return 2
  }
  
  // MARK: - TableView Datasource
  
  func numberOfSections(in tableNode: ASTableNode) -> Int {
    if model == nil { return 0 }
    
    var target = 3
    
    if trophies.count == 0 {
      target -= 1
    }
    
    if subreddits.count == 0 {
      target -= 1
    }
    
    return target
  }
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      if let user = model, user.username ~== Keychain.shared.preferredUsername {
        return UserRows.accountRows.count + 1
      } else {
        return UserRows.userRows.count + 1
      }
    }
    return 1
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    if indexPath.section == 0 {
      return getOverviewCell(for: indexPath)
    }
    
    if indexPath.section == trophySection {
      return { 
        return TrophyCollectionCellNode(trophies: self.trophies)
      }
    }
    
    if indexPath.section == activeSection {
      return { 
        return ActiveSubredditCollectionCellNode(subreddits: self.subreddits)
      }
    }
    
    return { 
      ASCellNode()
    }
  }
  
  
  // MARK: - Tableview Delegate

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.section == 0 else { return }
    guard let vc = controller(forRowAt: indexPath) else { return }

    // TODO: Check that if not presentable, show is used
    display(vc)
  }
  
  private func controller(forRowAt indexPath: IndexPath) -> UIViewController? {
    let userModel = model.unsafelyUnwrapped

    guard let row = UserRows(rawValue: indexPath.row) else {
      return nil
    }
    
    switch row {
    case .submitted:
      let model = UserSubmissionModel(user: userModel.user)
      let vc = UserListingsViewController(model: model)
      vc.title = "Submitted"
      return vc
    case .comments:
      let vc = UserCommentsViewController(user: userModel.user)
      vc.title = "Comments"
      return vc

    case .saved:
      let model = UserSavedModel(user: userModel.user)
      let vc = UserListingsViewController(model: model)
      vc.title = "Saved"
      return vc

    case .hidden:
      let model = UserHiddenModel(user: userModel.user)
      let vc = UserListingsViewController(model: model)
      vc.title = "Hidden"
      return vc

    case .upvoted:
      let model = UserUpvotedModel(user: userModel.user)
      let vc = UserListingsViewController(model: model)
      vc.title = "Upvoted"
      return vc

    case .downvoted:
      let model = UserDownvotedModel(user: userModel.user)
      let vc = UserListingsViewController(model: model)
      vc.title = "Downvoted"
      return vc
    }
  }

  // MARK: - Row helpers
  
  private func getOverviewCell(for indexPath: IndexPath) -> ASCellNodeBlock {
    if indexPath.row == 0 {
      return { [weak self] in
        guard let user = self?.model?.user else { return ASCellNode() }
        return ProfileOverviewCellNode(user: user)
      }
    } else {
      return getBasicCell(for: indexPath)
    }
  }
  
  private func getBasicCell(for indexPath: IndexPath) -> ASCellNodeBlock {

    guard let row = UserRows(rawValue: indexPath.row) else {
      return { ASCellNode() }
    }

    switch row {
    case .submitted:
      return basicCell(title: "Submitted")
    case .comments:
      return basicCell(title: "Comments")
    case .saved:
      return basicCell(title: "Saved")
    case .hidden:
      return basicCell(title: "Hidden")
    case .upvoted:
      return basicCell(title: "Upvoted")
    case .downvoted:
      return basicCell(title: "Downvoted")
    }

  }
  
  private func basicCell(title: String) -> ASCellNodeBlock {
    return { 
      let cell = BasicCellNode(backgroundColor: .secondarySystemGroupedBackground)
      cell.text = title
      
      return cell
    }
  }
  
}
