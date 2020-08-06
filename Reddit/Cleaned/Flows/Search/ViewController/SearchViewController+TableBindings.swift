//
//  SearchViewController+TableBindings.swift
//  Reddit
//
//  Created by made2k on 6/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Differentiator
import RxASDataSources
import RxSwift

extension SearchViewController {
  
  func setupTableBindings() {
    
    let links = model.linkResultsObserver
      .map { $0.prefix(4) }
      .map { Array($0) }
      .map { $0.isEmpty ? $0 : $0 + [nil] } // Add the empty cell for "view all"
      .mapMany { SearchSectionItem.LinkSectionItem(link: $0) }
      .map { return SearchSectionModel.LinkProvidableSection(title: R.string.search.linkSectionHeader(), items: $0) }

    let users = model.userResultsObserver
      .mapMany { SearchSectionItem.UserSectionItem(user: $0) }
      .map { return SearchSectionModel.UserProvidableSection(title: R.string.search.userSectionHeader(), items: $0) }

    let subreddits = model.subredditResultsObserver
      .mapMany { SearchSectionItem.SubredditSectionItem(subreddit: $0) }
      .map { return SearchSectionModel.SubredditProvidableSection(title: R.string.search.subredditSectionHeader(), items: $0) }


    let datasource = SearchViewController.dataSource()
    
    Observable.combineLatest(links, users, subreddits) { [$0, $1, $2] }
      .map { $0.filter { $0.items.isNotEmpty } } // Only include sections with data
      .bind(to: node.rx.items(dataSource: datasource))
      .disposed(by: disposeBag)
    
    node.rx
      .modelSelected(SearchSectionItem.self)
      .subscribe(onNext: { [unowned self] in
        self.modelSelected($0)
      }).disposed(by: disposeBag)
    
  }
  
}
