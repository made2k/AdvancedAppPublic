//
//  SearchViewController+TableDelegate.swift
//  Reddit
//
//  Created by made2k on 6/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

extension SearchViewController {

  func modelSelected(_ model: SearchSectionItem) {

    switch model {
    case .LinkSectionItem(link: let value): didSelectLink(value)
    case .UserSectionItem(user: let value): didSelectUser(value)
    case .SubredditSectionItem(subreddit: let value): didSelectSubreddit(value)
    }

  }

  private func didSelectLink(_ link: LinkModel?) {
    
    guard let link = link else {
      return didSelectShowAllLinks()
    }

    delegate.didSelectLinkModel(link)
  }
  
  private func didSelectShowAllLinks() {
    delegate.didSelectShowAllLinks()
  }
  
  private func didSelectUser(_ user: UserModel) {
    delegate.didSelectUser(user)
  }
  
  private func didSelectSubreddit(_ result: SubredditSearchResult) {
    delegate.didSelectSubreddit(result)
  }
  
}
