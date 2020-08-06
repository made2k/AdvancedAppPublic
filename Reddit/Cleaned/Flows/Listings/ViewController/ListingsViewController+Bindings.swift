//
//  ListingsViewController+Bindings.swift
//  Reddit
//
//  Created by made2k on 1/2/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Haptica
import RxSwift
import UIKit

extension ListingsViewController {

  func setupBindings() {

    setupButtonBindings()
    setupTableBindings()
    setupInboxBindings()
    setupHideReadBindings()
    setupReloadableBindings()
    setupSignedInUserBindings()
  }

  private func setupButtonBindings() {

    SplitCoordinator.currentObserver
      .filterNil()
      .flatMap(\.splitViewController.isInSplitView)
      .map { !$0 }
      .subscribe(onNext: { [weak self] in
        self?.configureRightBarButtonItems(showOptions: $0)
      }).disposed(by: disposeBag)

    hideReadButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.hideReadButtonPressed()
      }).disposed(by: disposeBag)

    hideReadButton.rx.longPressGesture()
      .when(.began)
      .filter { _ in
        AccountModel.currentAccount.value.isSignedIn
      }
      .subscribe(onNext: { [weak self] _ in
        Haptic.longPress()
        self?.hideReadButtonLongPressed()
      }).disposed(by: disposeBag)

  }

  func setupListingBindings(_ listingDisplay: ListingDisplay) {

    postLoadDisposeBag = DisposeBag()

    listingDisplay.sortType.asDriver()
      .map { $0.icon.barButtonSafe }
      .drive(onNext: { [unowned self] image in
        self.sortBarButtonItem.image = image
      }).disposed(by: postLoadDisposeBag)
  }

  private func setupTableBindings() {

    let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)

    let initialDelay: DispatchTimeInterval = .seconds(2)
    let titleThrottle: DispatchTimeInterval = .milliseconds(200)

    let scrollObservable = tableNode.view.rx.observe(CGPoint.self, "contentOffset")
      .filterNil()
      .distinctUntilChanged()
      .withPrevious(startWith: tableNode.contentOffset)
      .skip(initialDelay, scheduler: backgroundScheduler)
      .map { ($0.y, $1.y ) }
      .subscribeOn(backgroundScheduler)
      .share()

    // Manage hiding / showing the title view
    scrollObservable
      .throttle(titleThrottle, scheduler: MainScheduler.asyncInstance)
      .map { $0.1 }
      .observeOn(MainScheduler.asyncInstance)
      .map { [weak self] in
        let statusBarHeight: CGFloat = self?.view.statusBarHeight ?? 0
        return $0 < -1 * (44 + statusBarHeight)
      }
      .map { [weak self] isInRange -> Bool in
        isInRange && self?.navigationController?.navigationBar.prefersLargeTitles == true
      }
      .subscribe(onNext: { [weak self] hidden in
        self?.navigationTitleView.isHidden = hidden
      }).disposed(by: disposeBag)

  }

  private func setupInboxBindings() {

    InboxWatcher.shared.unreadCount
      .map { $0 <= 0 }
      .distinctUntilChanged()
      .subscribe(onNext: { [unowned self] hideInboxButton in
        let leftItem: UIBarButtonItem? = hideInboxButton ? nil : self.unreadBarButtonItem
        self.navigationItem.leftBarButtonItem = leftItem
      }).disposed(by: disposeBag)

  }

  private func setupHideReadBindings() {

    Settings.showHideReadButton
      .bind(to: hideReadButton.rx.isVisible)
      .disposed(by: disposeBag)

  }

  private func setupReloadableBindings() {

    Observable.combineLatest(Settings.previewTitleFirst.asObservable(),
                             Settings.thumbnailSide.asObservable(),
                             Settings.showLinkFlair.asObservable())
    { _, _, _ in }
      .subscribe(onNext: { [unowned self] _ in
        self.reloadData(maintainScrollPosition: true)
      }).disposed(by: disposeBag)

  }

  private func setupSignedInUserBindings() {

    AccountModel.currentAccount
      .distinctUntilChanged { $0.username == $1.username }
      .subscribe(onNext: { [unowned self] _ in
        self.delegate?.refresh(with: nil)
      }).disposed(by: disposeBag)

  }

}
