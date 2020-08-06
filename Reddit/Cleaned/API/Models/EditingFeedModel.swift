//
//  EditingFeedModel.swift
//  Reddit
//
//  Created by made2k on 6/30/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI

class EditingFeedModel: ViewModel {
  
  private var editingModel: FeedModel?
  var feedName: String?
  var feedDescription: String?
  var subredditNames: [String] = []
  
  var isCreating: Bool { return editingModel == nil }
  
  init(feedModel: FeedModel?) {
    self.editingModel = feedModel
    feedName = feedModel?.title
    feedDescription = feedModel?.feedDescription
    subredditNames = feedModel?.subredditNames ?? []
  }
  
  // MARK: - Updating
  
  func save() -> Promise<FeedModel> {
    
    if let existingModel = editingModel {
      return updateFeed(model: existingModel).map { existingModel }
    }
    
    return createFeed()
  }
  
  private func updateFeed(model: FeedModel) -> Promise<Void> {

    guard let name = feedName else {
      return .error(OldAPIError.invalidRequest)
    }

    return model.updateFeed(name: name,
                            description: feedDescription,
                            subreddits: subredditNames)
  }
  
  private func createFeed() -> Promise<FeedModel> {

    guard let name = feedName else {
      return .error(OldAPIError.invalidRequest)
    }
    
    return firstly {
      api.session.performFeedUpdate(feedPath: nil,
                                    displayName: name,
                                    description: feedDescription,
                                    subreddits: subredditNames)
      
    }.map {
      return FeedModel(feed: $0)
      
    }.get {
      self.editingModel = $0
    }
    
  }
  
  func addSubreddit(_ name: String) -> Promise<Void> {
    guard let editingModel = editingModel else {
      subredditNames.append(name)
      return .value(())
    }
    
    return firstly {
      editingModel.addSubreddit(name)
      
    }.done {
      self.subredditNames.append(name)
    }
    
  }
  
  func removeSubreddit(_ name: String) -> Promise<Void> {
    guard let editingModel = editingModel else {
      subredditNames.remove(name)
      return .value(())
    }
    
    return firstly {
      editingModel.removeSubreddit(name)
      
    }.done {
      self.subredditNames.remove(name)
    }
    
  }
  

}
