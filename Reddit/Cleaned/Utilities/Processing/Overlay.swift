//
//  Overlay.swift
//  Reddit
//
//  Created by made2k on 1/25/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import SVProgressHUD
import RxSwift
import UIKit

class Overlay: NSObject {
  
  static let shared = Overlay()
  private let disposeBag = DisposeBag()
  
  private override init() {
    SVProgressHUD.setMaxSupportedWindowLevel(UIWindow.Level(rawValue: 1))
    
    // TODO: There's a bug in SVProgressHUD that prevents images already in .template from showing
    SVProgressHUD.setErrorImage(R.image.icon_report().unsafelyUnwrapped.withRenderingMode(.automatic))
    SVProgressHUD.setSuccessImage(R.image.icon_checkmark().unsafelyUnwrapped.withRenderingMode(.automatic))
    
    super.init()
    
    setupBindings()
  }
  
  private func setupBindings() {

    SplitCoordinator.currentObserver
      .filterNil()
      .flatMap(\.interfaceObserver)
      .map { (interfaceStyle: UIUserInterfaceStyle) -> SVProgressHUDStyle in

        switch interfaceStyle {
        case .light, .unspecified:
          return SVProgressHUDStyle.light

        case .dark:
          return SVProgressHUDStyle.dark
          
        @unknown default:
          return SVProgressHUDStyle.dark
        }
      }
      .subscribe(onNext: {
        SVProgressHUD.setDefaultStyle($0)
      })
      .disposed(by: disposeBag)
    
  }

  func showProcessingOverlay(status: String? = nil) {
    SVProgressHUD.setDefaultMaskType(.clear)
    SVProgressHUD.show(withStatus: status)
  }

  func hideProcessingOverlay() {
    SVProgressHUD.popActivity()
  }

  func flashErrorOverlay(_ status: String, duration: TimeInterval = 1.5) {
    SVProgressHUD.setDefaultMaskType(.none)
    SVProgressHUD.showError(withStatus: status)
    SVProgressHUD.dismiss(withDelay: duration)
  }

  func flashSuccessOverlay(_ status: String, duration: TimeInterval = 1.5) {
    SVProgressHUD.setDefaultMaskType(.none)
    SVProgressHUD.showSuccess(withStatus: status)
    SVProgressHUD.dismiss(withDelay: duration)
  }

}
