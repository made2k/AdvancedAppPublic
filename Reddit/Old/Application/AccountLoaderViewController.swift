//
//  AccountLoaderViewController.swift
//  Reddit
//
//  Created by made2k on 5/21/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import PromiseKit
import SnapKit
import RxSwift

class AccountLoaderViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let launchScreen = R.storyboard.launchScreen.instantiateInitialViewController()?.view {
      view.addSubview(launchScreen)
      launchScreen.snp.makeConstraints({ (make) in
        make.edges.equalToSuperview()
      })
    }
    
  }
  
}

class TraitOverridingViewController: UIViewController {

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupBindings()
  }

  private func setupBindings() {
    
    Settings.iPadStyleOverride
      .distinctUntilChanged()
      .asVoid()
      .subscribe(onNext: { [unowned self] in
        self.setNeedsUpdate()
      }).disposed(by: disposeBag)
    
  }
  
  override func addChild(_ childController: UIViewController) {
    super.addChild(childController)
    
    guard Settings.iPadStyleOverride.value else { return }
    performOverrideTraitCollection()
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    
    if Settings.iPadStyleOverride.value {
      performOverrideTraitCollection()
      
    } else {
      super.viewWillTransition(to: size, with: coordinator)
    }
    
  }

  private func performOverrideTraitCollection() {
    for childVC in self.children {
      setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: .compact), forChild: childVC)
    }
  }

  private func setNeedsUpdate() {
    let animationDuration = 0.6
    
    let overlayView = UIView()
    overlayView.backgroundColor = .white
    overlayView.alpha = 0

    UIApplication.shared.activeWindow()?.addSubview(overlayView)

    overlayView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    firstly {

      UIView.animate(.promise, duration: animationDuration) {
        overlayView.alpha = 1
      }

    }.done { _ in

      if Settings.iPadStyleOverride.value {
        self.performOverrideTraitCollection()

      } else {
        for childVC in self.children {
          self.setOverrideTraitCollection(UITraitCollection(), forChild: childVC)
        }
      }

    }.then(on: .main) { _ -> Guarantee<Bool> in
      UIView.animate(.promise, duration: animationDuration) {
        overlayView.alpha = 0
      }

    }.done { _ in
      overlayView.removeFromSuperview()
    }
  }
}
