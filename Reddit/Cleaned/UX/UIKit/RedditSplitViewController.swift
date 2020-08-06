//
//  RedditSplitViewController.swift
//  Reddit
//
//  Created by made2k on 6/14/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import RxRelay
import RxSwift
import UIKit

class RedditSplitViewController: UISplitViewController {

  private let isInSplitViewRelay: BehaviorRelay<Bool>
  private(set) lazy var isInSplitView: Observable<Bool> = isInSplitViewRelay.asObservable()

  @DelayedImmutable private var interfaceStyleRelay: BehaviorRelay<UIUserInterfaceStyle>
  private(set) lazy var interfaceStyle: Observable<UIUserInterfaceStyle> = interfaceStyleRelay.asObservable()

  private let disposeBag = DisposeBag()

  // MARK: - Initialization
  
  init() {
    self.isInSplitViewRelay = BehaviorRelay<Bool>(value: UIDevice.current.userInterfaceIdiom == .pad)

    super.init(nibName: nil, bundle: nil)

    self.interfaceStyleRelay = BehaviorRelay<UIUserInterfaceStyle>(value: traitCollection.userInterfaceStyle)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupSizeOverride()
    // Setup initial trait values
    traitCollectionDidChange(traitCollection)

    setupBindings()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    let isRegular = traitCollection.horizontalSizeClass == .regular
    isInSplitViewRelay.accept(isRegular)

    interfaceStyleRelay.accept(traitCollection.userInterfaceStyle)
  }
  
  // MARK: - Navigation

  override func show(_ vc: UIViewController, sender: Any?) {
    if let navigation = viewControllers.first as? UINavigationController {
      navigation.pushViewController(vc, animated: true)

    } else {
      super.show(vc, sender: sender)
    }
  }
  
  override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
    guard viewControllers.contains(vc) == false else { return }
    super.showDetailViewController(vc, sender: sender)
  }
  
  // MARK: - Setup
  
  private func setupBindings() {
    
    Settings.splitViewColumnSizeOverride
      .subscribe(onNext: { [unowned self] _ in
        self.setupSizeOverride()
      }).disposed(by: disposeBag)

  }
  
  private func setupSizeOverride() {
    maximumPrimaryColumnWidth = max(view.bounds.width, view.bounds.height) / 2
    
    switch Settings.splitViewColumnSizeOverride.value {
    case .small:
      preferredPrimaryColumnWidthFraction = 0.35
    case .default:
      preferredPrimaryColumnWidthFraction = UISplitViewController.automaticDimension
    case .large:
      preferredPrimaryColumnWidthFraction = 0.475
    }
  }
  
}
