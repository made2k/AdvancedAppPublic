//
//  Dimable.swift
//  Reddit
//
//  Created by made2k on 9/4/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RxCocoa
import RxSwift
import UIKit

protocol Dimable: NSObjectProtocol {
  var alpha: CGFloat { get set }
  var image: UIImage? { get set }
}

private var associatedKey: Void?

extension Dimable where Self: NSObject {

  private var dimableDisposeBag: DisposeBag {
    get {
      return objc_getAssociatedObject(self, &associatedKey) as? DisposeBag ?? DisposeBag()
    }
    set {
      objc_setAssociatedObject(self, &associatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  func observeDimming() {

    dimableDisposeBag = DisposeBag()

    let threshold: CGFloat = 0.38
    let dimmedAlpha: CGFloat = 0.68
    let photoAnalysisSchedulder = SerialDispatchQueueScheduler(qos: .userInitiated)

    let dimEnabled = Settings.dimBrightImages
    let isDark = UIScreen.main.rx.brightness
      .map { $0 < threshold }
      .distinctUntilChanged()

    let isDarkMode: Observable<Bool> = SplitCoordinator.currentObserver
      .map { $0?.interfaceObserver }
      .replaceNilWith(Observable<UIUserInterfaceStyle>.just(.unspecified))
      .flatMap { $0 }
      .map { $0 == .dark }
      .distinctUntilChanged()

    let isImageBright = Observable.just(image).filterNil().map { $0.isBright }.subscribeOn(photoAnalysisSchedulder)

    Observable.combineLatest(dimEnabled, isDark, isDarkMode, isImageBright)
      .filter { $0.3 } // Image must be bright
      .map { $0.0 && $0.1 && $0.2 } // if dim enabled, screen is dark, in dark mode
      .map { $0 ? dimmedAlpha : 1 }
      .bind(to: rx.alpha)
      .disposed(by: dimableDisposeBag)
  }

}

private extension Reactive where Base: Dimable {

  var alpha: Binder<CGFloat> {
    return Binder(base) { dimable, alpha in
      dimable.alpha = alpha
    }
  }

}

extension ASImageNode: Dimable { }
extension UIImageView: Dimable { }
