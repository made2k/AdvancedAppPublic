//
//  ViewControllerLookup.swift
//  Reddit
//
//  Created by made2k on 6/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import SafariServices
import UIKit

struct ViewControllerLookup {

  static func match(_ url: URL, previewing: Bool = false) -> UIViewController {

    let match = LinkMatcher.matchUrl(url)

    switch match {
    case .table(tableData: let value): return matchTable(value)
    case .redditListing(subreddit: let value): return matchRedditListing(value)
    case .media(unresolvedUrl: let value): return matchMedia(value, preview: previewing)
    case .redditLink(let value): return matchRedditLink(value, url: url)
    case .redditUser(userName: let value): return matchRedditUser(value)
    case .redditVideo(url: let value): return matchVideo(value, previewing: previewing)
    case .subredditWiki(resolvedUrl: let value): return matchDefault(value)
    case .album(resolvedUrl: let value): return matchAlbum(value)
    default: return matchDefault(url)
    }

  }

  private static func matchAlbum(_ albumUrl: URL) -> UIViewController {

    let navigation = NavigationController()

    let coordinator = AlbumCoordinator(albumUrl: albumUrl, navigation: navigation)
    coordinator.start()

    return navigation
  }

  private static func matchDefault(_ url: URL) -> UIViewController {

    let reader = OpenInPreference.shared.browserPreference == .safariInAppReader

    let configuration = SFSafariViewController.Configuration()
    configuration.entersReaderIfAvailable = reader

    return RedditSafariViewController(url: url.safeScheme(), configuration: configuration)
  }

  private static func matchMedia(_ url: URL, preview: Bool) -> UIViewController {
    return preview ?
      ImagePreviewViewController(url: url) :
      OverviewMediaViewController(url: url)
  }

  private static func matchRedditLink(_ match: SubredditLinkMatch, url: URL) -> UIViewController {

    // We need to privide a seperate navigation context when presenting a preview
    // since it would otherwise start the coordinator on the split navigation
    let navigation = NavigationController()

    guard let coordinator = LinkHandler.coordinatorForLinkMatch(match, navigation: navigation) else {
      return matchDefault(url)
    }

    coordinator.start()
    return navigation

  }

  private static func matchRedditListing(_ subredditName: String) -> UIViewController {

    let delegate: ListingsCoordinatorDelegate = SplitCoordinator.current

    let coordinator = ListingsCoordinator(navigation: nil, delegate: delegate, subredditName: subredditName)
    coordinator.start()

    return coordinator.navigation
  }

  private static func matchRedditUser(_ userName: String) -> UIViewController {
    return UserOverviewViewController(userName: userName)
  }

  private static func matchTable(_ tableData: String) -> UIViewController {

    let navigation = NavigationController()

    let coordinator = HTMLTableCoordinator(navigation: navigation, tableData: tableData)
    coordinator.start()

    return navigation
  }
  
  private static func matchVideo(_ url: URL, previewing: Bool) -> UIViewController {
    guard previewing else { return matchDefault(url) }
    return matchMedia(url, preview: previewing)
  }

}
