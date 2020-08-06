//
//  StartupCoordinator.swift
//  Reddit
//
//  Created by made2k on 12/28/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Logging
import PromiseKit
import UIKit

class StartupCoordinator: NSObject, Coordinator {

  private let window: UIWindow
  private let waitingGuarantee: Guarantee<Void>
  private let controller = AccountLoaderViewController()

  private var splitCoordinator: SplitCoordinator?
  private var autosaveCoordinator: Coordinator?
  private var sideMenuCoordinator: SideMenuCoordinator?

  init(window: UIWindow, waitingOn: Guarantee<Void>) {
    self.window = window
    self.waitingGuarantee = waitingOn
  }

  func start() {
    window.rootViewController = controller
    window.makeKeyAndVisible()

    sideMenuCoordinator = SideMenuCoordinator(window: window)
    sideMenuCoordinator?.start()
    
    startFlow()
  }

  private func showSplitView() {
    splitCoordinator = SplitCoordinator(window: window)
    splitCoordinator?.start()

    if let splitViewController = splitCoordinator?.splitViewController {
      autosaveCoordinator = AutoSaveCoordinator(controller: splitViewController)
      autosaveCoordinator?.start()
    }
  }

  private func startFlow() {
    log.verbose("Starup coordinator is beginning the flow")
    
    firstly {
      waitingGuarantee
      
    }.then { _ -> Promise<Void> in
      self.loadUserPromise()
      
    }.done {
      self.showSplitView()

    }.catch { error in
      log.error("Failed to load user", error: error)
      self.showLoadError()
    }

  }
  
  private func loadUserPromise() -> Promise<Void> {
    
    let accountPromise: Promise<AccountModel>
    
    if let token = Keychain.shared.activeToken() {
      accountPromise = attempt(maximumRetryCount: 3, delayBeforeRetry: .seconds(2)) {
        AccountModel.loadAccount(token: token)
      }
    
    } else {
      accountPromise = .value(AccountModel.currentAccount.value)
    }
    
    return firstly {
      accountPromise
      
    }.get {
      AccountModel.currentAccount.accept($0)
      log.info("coordinator successfully fetched user \(String(describing: $0.username))")
      
    }.done {
      $0.getSubscribedSubreddits().cauterize()
      $0.getSubscribedFeeds().cauterize()
      
    }
    
  }

  private func showLoadError() {
    
    let alert = UIAlertController(title: nil,
                                  message: R.string.startup.userLoadFailedMessage(),
                                  preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: R.string.startup.tryAgain(), style: .default) { [unowned self] _ in
      self.startFlow()
    })

    alert.addAction(UIAlertAction(title: R.string.startup.signOut(), style: .destructive) { [unowned self] _ in
      guard let currentUser = Keychain.shared.preferredUsername else { return }
      Keychain.shared.remove(username: currentUser)
      self.startFlow()
    })

    controller.present(alert)
  }

}
