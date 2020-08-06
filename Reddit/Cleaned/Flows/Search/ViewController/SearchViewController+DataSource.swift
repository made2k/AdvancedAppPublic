//
//  SearchViewController+DataSource.swift
//  Reddit
//
//  Created by made2k on 6/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI
import RxASDataSources

extension SearchViewController {

  static func dataSource() -> RxASTableAnimatedDataSource<SearchSectionModel> {

    let dataSource = RxASTableAnimatedDataSource<SearchSectionModel>(configureCellBlock: { (dataSource, table, indexPath, item) -> ASCellNodeBlock in

      switch dataSource[indexPath] {

      case .LinkSectionItem(link: let link):
        return linkBlock(for: link)

      case .UserSectionItem(user: let user):
        return userBlock(for: user)

      case .SubredditSectionItem(subreddit: let subreddit):
        return subredditBlock(for: subreddit)

      }

    })

    dataSource.titleForHeaderInSection = { dataSource, index in
      guard let section = dataSource.sectionModels[safe: index] else { return nil }
      return section.title
    }

    dataSource.animationConfiguration = RowAnimation(insertAnimation: .automatic, reloadAnimation: .fade, deleteAnimation: .fade)

    return dataSource

  }

  private static func linkBlock(for model: LinkModel?) -> ASCellNodeBlock {

    guard let model = model else { return seeMoreBlock() }

    return  {
      let node = ListingsCellFactory.cellFor(model: model, previewType: .thumbnail, delegate: nil)
      node.backgroundColor = .secondarySystemGroupedBackground
      return node
    }

  }

  private static func seeMoreBlock() -> ASCellNodeBlock {

    return {
      let node = ThemeableTextCellNode(backgroundColor: .secondarySystemGroupedBackground)
      node.selectionStyle = .none
      node.titleNode.text = R.string.search.seeMore()
      return node
    }

  }

  private static func userBlock(for user: UserModel) -> ASCellNodeBlock {

    return {
      let node = ThemeableTextCellNode(backgroundColor: .secondarySystemGroupedBackground)
      node.selectionStyle = .none
      node.titleNode.text = user.username
      node.accessoryImage = R.image.icon_user()
      return node
    }

  }

  private static func subredditBlock(for subreddit: SubredditSearchResult) -> ASCellNodeBlock {

    return {
      let node = ThemeableTextCellNode(backgroundColor: .secondarySystemGroupedBackground)
      node.selectionStyle = .none
      node.titleNode.text = subreddit.name
      return node
    }

  }

}
