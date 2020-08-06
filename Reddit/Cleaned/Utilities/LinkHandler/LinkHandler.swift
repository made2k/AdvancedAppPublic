//
//  LinkHandler.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import Logging
import PromiseKit
import UIKit

struct LinkHandler {
  
  // MARK: - Properties
  
  private static var splitViewController: UISplitViewController {
    return SplitCoordinator.current.splitViewController
  }
  private static var splitMasterNavigation: UINavigationController {
    return SplitCoordinator.current.masterNavigation
  }
  private static var splitDetailNavigation: UINavigationController {
    return SplitCoordinator.current.detailNavigation
  }
  
  // TODO: See if this is needed anymore
  private static let shortSpoilerPrefix = "#"
  
  // MARK: - URL Handling
  
  static func handleUrl(_ url: URL) {

    let urlString: String = url.absoluteString

    guard urlString.hasPrefix(shortSpoilerPrefix) == false else { return }

    // Remove our link handler if applicable
    let safeUrl: URL

    let urlHandler: String = "advreddit://"

    if urlString.hasPrefix(urlHandler) {

      var unprefixedUrlString = urlString.removingPrefix("advreddit://")
      unprefixedUrlString = unprefixedUrlString.replacingOccurrences(of: "http//", with: "http://")
      unprefixedUrlString = unprefixedUrlString.replacingOccurrences(of: "https//", with: "https://")
      unprefixedUrlString = unprefixedUrlString.substringOrSelf(after: "reddit.com")

      var urlComponents = URLComponents(string: unprefixedUrlString)
      urlComponents?.scheme = "https"
      urlComponents?.host = "www.reddit.com"

      guard let fixedUrl = urlComponents?.url else {
        return
      }

      safeUrl = fixedUrl

    } else {
      safeUrl = url
    }

    log.debug("handling url: \(safeUrl.absoluteString)")
    
    let match = LinkMatcher.matchUrl(safeUrl)
    
    switch match {
    case .album(resolvedUrl: let value): openAlbum(value)
    case .appStore(appStoreUrl: let value): systemOpenUrl(value)
    case .composeMessage(let value): openMessageCompose(value)
    case .media(unresolvedUrl: let value): openMedia(value)
    case .redditLink(let value): openRedditLink(value)
    case .redditListing(subreddit: let value): openRedditListing(value)
    case .redditUser(userName: let value): openRedditUser(userName: value)
    case .redditSubmission(match: let value): openRedditSubmission(value)
    case .redditVideo(url: let value): openVideo(url: value)
    case .subredditWiki(resolvedUrl: let value): openBrowserPreference(value)
    case .table(tableData: let value): handleTableData(value)
    case .youtube(youtubeUrl: let value): openYoutube(value)
    case .unknown(url: let value): openBrowserPreference(value)
    }
    
  }

  /**
   Handle an HTML table encoded into a URL for display
   */
  private static func handleTableData(_ tableData: String) {

    HTMLTableCoordinator(
      navigation: splitDetailNavigation,
      tableData: tableData)
      .start()

  }

  private static func openAlbum(_ url: URL) {
    AlbumCoordinator(
      albumUrl: url,
      navigation: splitDetailNavigation)
      .start()
  }

  private static func openBrowserPreference(_ url: URL) {
    OpenInPreference.shared.openBrowser(url: url)
  }
  
  private static func openMedia(_ url: URL) {
    // TODO: If noticing failed images, modify mediaViewController to open webpage
    let controller = OverviewMediaViewController(url: url)
    splitViewController.present(controller)
  }
  
  private static func openMessageCompose(_ value: MessageComposeMatch) {

    // TODO: Throw an error here?
    let account = AccountModel.currentAccount.value
    guard account.isSignedIn else { return }
    
    let vc = ComposeMessageViewController(model: account.inboxModel,
                                          username: value.recipient,
                                          subject: value.subject,
                                          message: value.message)
    
    let nav = NavigationController(controllers: vc)
    nav.modalPresentationStyle = .formSheet
    
    splitViewController.present(nav)
  }
  
  static func openRedditLink(_ match: SubredditLinkMatch) {
    guard let coordinator = coordinatorForLinkMatch(match) else { return }
    coordinator.start()
  }

  private static func openRedditListing(_ subredditName: String) {

    if let currentSubredditName = (splitMasterNavigation.viewControllers.last as? ListingsViewController)?.subredditName {
      if currentSubredditName ~== subredditName { return }
    }

    Overlay.shared.showProcessingOverlay()

    firstly {
      after(seconds: 0.4)

    }.then {
      SubredditModel.verifySubredditExists(path: subredditName)

    }.done {
      Overlay.shared.hideProcessingOverlay()
      SplitCoordinator.current.openListing($0)

    }.catch { _ in
      Overlay.shared.flashErrorOverlay(R.string.linkHandler.subredditNotFound(subredditName))
    }

  }
  
  private static func openRedditSubmission(_ match: SubmissionMatch) {
    
    Overlay.shared.showProcessingOverlay()
    
    firstly {
      SubredditModel.verifySubredditExists(path: match.subredditName)
      
    }.done { model in
      guard let subreddit = model.subreddit else { return }

      let presenter = SplitCoordinator.current.splitViewController
      SubmissionCoordinator(presenter: presenter, subreddit: subreddit, autoSave: nil).start()

    }.ensure {
      Overlay.shared.hideProcessingOverlay()
    }
    
  }

  static func openRedditUser(userName: String) {
    let userVC = UserOverviewViewController(userName: userName)
    splitViewController.show(userVC, sender: self)
  }
  
  private static func openVideo(url: URL) {
    return openBrowserPreference(url)
  }

  private static func openYoutube(_ url: URL) {
    OpenInPreference.shared.openYoutube(url: url)
  }

  private static func systemOpenUrl(_ url: URL) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }

  // MARK: - Helpers

  // TODO: This should be handled elsewhere
  static func coordinatorForLinkMatch(
    _ match: SubredditLinkMatch,
    navigation: UINavigationController? = nil) -> LinkCoordinator? {
    
    let coordinatorNavigation = navigation ?? splitDetailNavigation
    
    let coordinator = LinkCoordinator(linkMatch: match, navigation: coordinatorNavigation)
    coordinator.focusingId.accept(match.focusId)
    
    return coordinator
  }

  static func viewController(for url: URL, previewing: Bool = false) -> UIViewController {
    return ViewControllerLookup.match(url, previewing: previewing)
  }
  
}
